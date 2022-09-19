module Api::V1::Teams::ControllerBase
  extend ActiveSupport::Concern

  module StrongParameters
    # Only allow a list of trusted parameters through.
    def self.team_params(params, permitted_fields, permitted_arrays)
      strong_params = params.require(:team).permit(
        *permitted_fields,
        :name,
        :time_zone,
        :locale,
        # 🚅 super scaffolding will insert new fields above this line.
        *permitted_arrays,
        # 🚅 super scaffolding will insert new arrays above this line.
      )

      Account::TeamsController.process_params(strong_params)

      strong_params
    end
  end

  included do
    load_and_authorize_resource :team, class: "Team", prepend: true,
      member_actions: (defined?(MEMBER_ACTIONS) ? MEMBER_ACTIONS : []),
      collection_actions: (defined?(COLLECTION_ACTIONS) ? COLLECTION_ACTIONS : [])

    private

    include StrongParameters
  end

  # GET /api/v1/teams
  def index
  end

  # GET /api/v1/teams/:id
  def show
  end

  # PATCH/PUT /api/v1/teams/:id
  def update
    if @team.update(StrongParameters.team_params(params, permitted_fields, permitted_arrays))
      render :show
    else
      render json: @team.errors, status: :unprocessable_entity
    end
  end
end
