require "pry"

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

      [
        "app/controllers/api/#{new_version}",
        "app/views/api/#{new_version}",
        "test/controllers/api/#{new_version}"
      ].each do |dir|
        Dir.mkdir(dir)
      end

      files_to_update = [
        "config/routes/api/#{previous_version}.rb",
        Dir.glob("app/controllers/api/#{previous_version}/**/*.rb") +
        Dir.glob("app/views/api/#{previous_version}/**/*.json.jbuilder") +
        Dir.glob("test/controllers/api/#{previous_version}/**/*.rb")
      ].flatten

      files_to_update.each do |file_name|
        previous_file_contents = File.open(file_name).readlines
        new_file_name = file_name.gsub(previous_version, new_version)

        # i.e. Api::V1::ApplicationController > Api::V2::ApplicationController.
        updated_file_contents = previous_file_contents.map do |line|
          if line.match?(previous_version)
            line.gsub(previous_version, new_version)
          else
            line.gsub("Api::#{previous_version.upcase}", "Api::#{new_version.upcase}")
          end
        end

        # We have to account for any other directories that exist under #{api/previous_version}
        # but haven't been created yet in #{api/new_version}
        # i.e. - api/v2/projects/pages.json.jbuilder.
        new_version_dir, dir_hierarchy = new_file_name.split(/(?<=#{new_version})\//)
        if dir_hierarchy.present? && dir_hierarchy.match?("/")
          dir_hierarchy = dir_hierarchy.split("/")
          dir_hierarchy.inject(new_version_dir) do |base, child_dir_or_file|
            # Stop making new directories if the string has an extention like ".rb"
            break if child_dir_or_file.match?(/\./)

            new_hierarchy = "#{base}/#{child_dir_or_file}"
            Dir.mkdir(new_hierarchy) unless Dir.exists?(new_hierarchy)
            new_hierarchy
          end
        end
        # TODO: I'd like to use Scaffolding::FileManipulator for this.
        File.open(new_file_name, "w") {|f| f.write(updated_file_contents.join)}
      end

      # Here we make sure config/api/#{new_version}.rb is called from within the main routes file.
      previous_file_contents = File.open("config/routes.rb").readlines
      updated_file_contents = previous_file_contents.map do |line|
        if line.match?("draw \"api/#{previous_version}\"")
          new_version_draw_line = line.gsub(previous_version, new_version)
          line + new_version_draw_line
        else
          line
        end
      end
      # TODO: I'd like to use Scaffolding::FileManipulator for this.
      File.open("config/routes.rb", "w") {|f| f.write(updated_file_contents.join)}

      puts "Finished bumping to #{new_version}"
    end
  end
end
