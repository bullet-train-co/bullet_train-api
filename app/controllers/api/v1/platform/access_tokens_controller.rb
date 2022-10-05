# Api::V1::ApplicationController is in the starter repository and isn't
# needed for this package's unit tests, but our CI tests will try to load this
# class because eager loading is set to `true` when CI=true.
# We wrap this class in an `if` statement to circumvent this issue.
if defined?(Api::V1::ApplicationController)
  class Api::V1::Platform::AccessTokensController < Api::V1::ApplicationController
    account_load_and_authorize_resource :access_token, through: :application, through_association: :access_tokens

    # GET /api/v1/platform/access_tokens/:id
    def show
    end

    # POST /api/v1/platform/applications/:application_id/access_tokens
    def create
      @access_token.provisioned = true

      if @access_token.save
        render :show, status: :created, location: [:api, :v1, @access_token]
      else
        render json: @access_token.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/platform/access_tokens/:id
    def update
      if @access_token.update(access_token_params)
        render :show
      else
        render json: @access_token.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/platform/access_tokens/:id
    def destroy
      @access_token.destroy
    end

    private

    module StrongParameters
      # Only allow a list of trusted parameters through.
      def access_token_params
        strong_params = params.require(:platform_access_token).permit(
          *permitted_fields,
          :description,
          # 🚅 super scaffolding will insert new fields above this line.
          *permitted_arrays,
          # 🚅 super scaffolding will insert new arrays above this line.
        )

        process_params(strong_params)

        strong_params
      end
    end

    include StrongParameters
  end
else
  class Api::V1::Platform::AccessTokensController
  end
end
