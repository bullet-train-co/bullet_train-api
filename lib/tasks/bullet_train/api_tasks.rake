namespace :bullet_train do
  namespace :api do
    desc "Registers your production API documentation to Redocly"
    task :push_to_redocly do
      # TODO: Generate yaml file with ENV["BASE_URL"]
      # and push with redocly cli.
    end
  end
end
