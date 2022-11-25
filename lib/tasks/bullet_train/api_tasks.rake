namespace :bullet_train do
  namespace :api do
    desc "Registers your production API documentation to Redocly"
    task :push_to_redocly do
      if Rails.env.production?
        if !ENV["BASE_URL"].present?
          raise "Your BASE_URL must be set before pushing documentation to Redocly."
        elsif !ENV["REDOCLY_AUTHORIZATION"].present?
          raise "You need to set your Redocly API key to ENV['REDOCLY_AUTHORIZATION'] so we can push your documentation to Redocly's API Registry."
        else
          puts "Before starting, make sure you have already created an API with the base documentation in Redocly's API Registry"
          puts ""

          # Grab the organization id and/or file name if provided in parameters.
          ARGV.shift
          api_option = ARGV.shift

          if api_option.nil? && !(File.exist?(".redocly.yaml") || File.exist?("redocly.yaml"))
            puts "Please tell us your organization id.".blue
            puts "i.e. your-test-app"
            puts "If you're unsure what this value is, please look at these steps in the documentation:"
            puts "https://redocly.com/docs/cli/commands/push/#organization-id"
            puts ""

            organization_id = $stdin.gets.chomp
            puts ""

            puts "Please tell us your file name.".blue
            puts "i.e. core@v1"
            puts "If you're unsure what this value is, please look at these steps in the documentation:"
            puts "https://redocly.com/docs/cli/commands/push/#api-name"
            puts ""

            file_name = $stdin.gets.chomp
            puts ""

            api_option = "@#{organization_id}/#{file_name}"
          end

          # Validate the file's contents before downloading it.
          `yarn exec redocly lint #{ENV["BASE_URL"]}/api/v1/openapi.yaml`

          # Get the file.
          `curl #{ENV["BASE_URL"]}/api/v1/openapi.yaml -o openapi.yaml`

          # Push to Redocly
          `REDOCLY_AUTHORIZATION=#{ENV["REDOCLY_AUTHORIZATION"]} yarn exec redocly push openapi.yaml #{api_option}`

          # Clean up
          `rm openapi.yaml`
        end
      else
        puts "This task is only available for applications in production.".red
      end
    end
  end
end
