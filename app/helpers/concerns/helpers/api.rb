module Helpers::Api
  def render_pagination(json)
    if @pagy
      json.has_more @pagy.has_more
    end
  end

  def to_api_json
    # TODO So many performance improvements available here.
    controller = "Api::#{BulletTrain::Api.current_version.upcase}::ApplicationController".constantize.new
    # TODO We need to fix host names here.
    controller.request = ActionDispatch::Request.new({})
    local_class_key = self.class.name.underscore.split("/").last.to_sym
    controller.render_to_string(
      "api/#{BulletTrain::Api.current_version}/#{self.class.name.underscore.pluralize}/_#{local_class_key}",
      locals: {
        local_class_key => self
      }
    )
  end
end
