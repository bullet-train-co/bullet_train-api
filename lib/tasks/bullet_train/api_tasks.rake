namespace :bullet_train do
  namespace :api do
    task :bump_version do
      # Calculate new version.
      initializer_content = File.new("config/initializers/api.rb").readline
      previous_version = initializer_content.scan(/v\d+/).pop
      new_version = "v#{previous_version.scan(/\d+/).pop.to_i + 1}"

      # Update initializer.
      File.open("config/initializers/api.rb", "w") do |f|
        f.write(initializer_content.gsub(previous_version, new_version))
      end
    end
  end
end
