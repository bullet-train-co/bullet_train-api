module Helpers::Api
  def render_pagination(json)
    if @pagy
      json.has_more @pagy.has_more
    end
  end
end
