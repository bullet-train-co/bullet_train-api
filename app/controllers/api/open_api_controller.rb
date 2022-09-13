module OpenApiHelper
  def indent(string, count)
    lines = string.lines
    first_line = lines.shift
    lines = lines.map { |line| ("  " * count).to_s + line }
    lines.unshift(first_line).join.html_safe
  end

  def components_for(model)
    for_model model do
      indent(render("api/#{@version}/open_api/#{model.name.underscore.pluralize}/components"), 2)
    end
  end

  def current_model
    @model_stack.last
  end

  def for_model(model)
    @model_stack ||= []
    @model_stack << model
    result = yield
    @model_stack.pop
    result
  end

  def paths_for(model)
    for_model model do
      indent(render("api/#{@version}/open_api/#{model.name.underscore.pluralize}/paths"), 1)
    end
  end

  def attribute(attribute)
    heading = t("#{current_model.name.underscore.pluralize}.fields.#{attribute}.heading")
    attribute_data = current_model.columns_hash[attribute.to_s]

    # TODO: File fields don't show up in the columns_hash. How should we handle these?
    # Default to `string` when the type returns nil.
    type = attribute_data.nil? ? "string" : attribute_data.type

    attribute_block = <<~YAML
      #{attribute}:
        description: "#{heading}"
        type: #{type}
    YAML
    indent(attribute_block.chomp, 2)
  end
  alias_method :parameter, :attribute
end

class Api::OpenApiController < ApplicationController
  helper :open_api

  def set_default_response_format
    request.format = :yaml
  end

  before_action :set_default_response_format

  def index
    @version = params[:version]
    render "api/#{@version}/open_api/index", layout: nil, format: :text
  end
end
