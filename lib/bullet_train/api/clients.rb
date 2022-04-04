# require './config/appliation.rb'

module BulletTrain
  module Api
    # Generates and publishes API clients for different languages
    class Clients
      CONFIG_FILENAME = 'config/clients.yml'.freeze
      LANGUAGES = %w[ruby python php node javascript java go swift].freeze

      attr_accessor :app_name, :config, :root_url, :languages

      def initialize(app_name)
        @app_name = app_name
        load_config
        @languages = config['targets'].keys
        @root_url = config['source']
      end

      def generate
        puts languages
        puts root_url
      end

      def publish
        puts 'wip'
      end

      private

      def load_config
        return @config if @config.present?
        return create_config unless File.exist?(CONFIG_FILENAME)

        @config ||= YAML.load_file(CONFIG_FILENAME)
      end

      def create_config
        conf = Hash.new
        conf['source'] = ask_root_url
        conf['targets'] = Hash.new
        ask_languages.each do |language|
          conf['targets'][language] = {
            repo: create_repo(language),
            package: generate_package_name(language),
            version: '1.0.0'
          }
        end

        File.open(CONFIG_FILENAME, 'w') do |file|
          file.write conf.to_yaml
        end

        @config = conf
      end

      def ask_root_url
        root_url_choice = ask """
No 'config/clients.yml' file found.
To create it, please write the root URL of #{app_name} production environment (It should look like `https://#{app_name.downcase}.com`.):
        """

        # TODO: Work the cases when user doesn't scpecify protocol,
        # specifies or not trailing backslash
        # and so on

        "#{root_url_choice}/api/swagger_doc.json"
      end

      def ask_languages
        languages_choice = ask """
Also please specify which languages do you want to support when generating API clients.
Available options are: #{LANGUAGES.join(', ')}.
Type them deviding with coma, or hit <Return> to include all:
          """

        languages_choice = languages_choice.split(',').map(&:strip)
        if languages_choice.empty?
          LANGUAGES
        else
          languages_choice.select { |language| LANGUAGES.include?(language) }
        end
      end

      def create_repo(language)
        ask """
Creating repository for #{language} API client.
Hit <Return> and we'll open a browser to GitHub where you can create a new repository.
When you're done, copy the SSH path from the new repository and return here.
We'll ask you to paste it to us in the next step.
        """
        
        command = Gem::Platform.local.os == 'linux' ? 'xdg-open' : 'open'
        `#{command} https://github.com/new`

        ask "OK, what was the SSH path? (It should look like `git@github.com:your-account/#{"#{app_name.underscore.dasherize}-#{language}"}.git`.)"
      end

      def generate_package_name(language)
        case language
        when 'ruby', 'python'
          app_name.underscore
        when 'php'
          "#{app_name.underscore.dasherize}/#{app_name.underscore.dasherize}"
        when 'node'
          "@#{app_name.underscore.dasherize}/#{app_name.underscore.dasherize}"

        # TODO: Crearify the rules for next languages
        when 'javascript'
          app_name.underscore
        when 'java'
          app_name.underscore
        when 'go'
          app_name.underscore
        when 'swift'
          app_name.underscore.dasherize
        end
      end

      ###
      def red(string)
        "\e[1;31m#{string}\e[0m"
      end

      def green(string)
        "\e[1;32m#{string}\e[0m"
      end

      def blue(string)
        "\e[1;34m#{string}\e[0m"
      end

      def yellow(string)
        "\e[1;33m#{string}\e[0m"
      end

      def ask(string)
        puts blue string
        $stdin.gets.strip
      end
    end
  end
end
