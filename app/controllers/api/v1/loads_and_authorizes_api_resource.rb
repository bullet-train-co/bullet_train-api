module Api::V1::LoadsAndAuthorizesApiResource
  extend ActiveSupport::Concern

  included do
    helpers do
      def load_and_authorize_api_resource(api_resource_class)
        raise unless api_resource_class.present?

        instance_variable_name = "@#{api_resource_class.name.demodulize.underscore}"
        instance_variable_collection_name = instance_variable_name.pluralize

        options = route.settings[:api_resource_options] || {permission: :read, skip_authorize: false}

        permission = options[:permission]
        skip_authorize = options[:skip_authorize]

        api_resource_params = declared(params, include_missing: false)
        api_resource_param_id = api_resource_params[:id]
        api_resource_params_other_ids = api_resource_params.select { |param, value|
          /_id$/i.match?(param)
        }

        unless permission.eql? :create
          resource_type = api_resource_param_id.present? ? :single_record : :collection
          resources = api_resource_class.accessible_by(current_ability, permission)

          # If there are no other ids (i.e. if we're doing a `show` action),
          # we simply get the original resources array.
          all_accessible_api_resources = resources.where(api_resource_params_other_ids)
          raise CanCan::AccessDenied if all_accessible_api_resources.empty?
        end

        if resource_type == :single_record # :show, :update, :destroy
          instance_variable_set(instance_variable_name, all_accessible_api_resources.find(api_resource_param_id))
        elsif resource_type == :collection # index
          instance_variable_set(instance_variable_collection_name, all_accessible_api_resources)
          skip_authorize = true # can't use CanCan to authorize collections
        elsif permission.eql? :create
          instance_variable_set(instance_variable_name, api_resource_class.new(api_resource_params))
        end

        eval "authorize! :#{permission}, #{instance_variable_name}" unless skip_authorize
      rescue ActiveRecord::RecordNotFound
        # the default RecordNotFound message includes the raw SQL... which feels bad
        handle_api_error(ActiveRecord::RecordNotFound.new("The id #{api_resource_param_id} could not be found."))
      rescue CanCan::AccessDenied
        handle_api_error(CanCan::AccessDenied.new("You are not authorized to access this data.", permission, api_resource_class))
      end
    end
  end
end
