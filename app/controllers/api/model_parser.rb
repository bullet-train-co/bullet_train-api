class Api::ModelParser < GrapeSwagger::Jsonapi::Parser
  attr_reader :model, :endpoint

  alias_method :schema, :call

  def initialize(model, endpoint)
    @model = model
    @endpoint = endpoint
  end

  def call
    # first let's grab the schema generated by the JSON:API parser
    schema_json = schema.to_json

    # From Nick Schneble:

    # we can easily override these types for our API endpoints in the documentation
    # but we can't do the same thing for the relationship objects that are auto-generated
    # thus the fancy affair below

    # if you want to learn more about what's happening here, read these:
    # https://stackoverflow.com/a/17918118/1322386
    # https://swagger.io/docs/specification/data-models/data-types/

    # Swagger 3.0 only supports a subset of Ruby data types
    schema_json.gsub!("\"type\":\"binary\"", "\"type\":\"string\", \"format\":\"binary\"")
    schema_json.gsub!("\"type\":\"date\"", "\"type\":\"string\", \"format\":\"date\"")
    schema_json.gsub!("\"type\":\"datetime\"", "\"type\":\"string\", \"format\":\"date-time\"")
    schema_json.gsub!("\"type\":\"decimal\"", "\"type\":\"number\", \"format\":\"double\"")
    schema_json.gsub!("\"type\":\"float\"", "\"type\":\"number\", \"format\":\"float\"")
    schema_json.gsub!("\"type\":\"bigint\"", "\"type\":\"integer\", \"format\":\"int64\"")
    schema_json.gsub!("\"type\":\"primary_key\"", "\"type\":\"integer\", \"format\":\"int64\"")
    schema_json.gsub!("\"type\":\"references\"", "\"type\":\"object\"")
    schema_json.gsub!("\"type\":\"text\"", "\"type\":\"string\"")
    schema_json.gsub!("\"type\":\"time\"", "\"type\":\"string\", \"format\":\"time\"")
    schema_json.gsub!("\"type\":\"timestamp\"", "\"type\":\"string\", \"format\":\"timestamp\"")
    schema_json.gsub!("\"type\":\"json\"", "\"type\":\"array\", \"items\":{\"type\":\"string\"}")

    # returns a Hash as if nothing fancy happened
    JSON.parse(schema_json)
  end
end
