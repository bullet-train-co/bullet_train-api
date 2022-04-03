module BulletTrain
  module Api
    # Generates and publishes API clients for different languages
    class Clients
      LANGUAGES = %w[ruby python php javascript java go swift].freeze

      attr_accessor :languages, :root_url

      def initialize
        @languages = find_languages
        @root_url = find_root_url
      end

      def generate
        puts 'HHH'
      end

      def publish
        puts 'PPP'
      end

      private

      def find_languages
        if File.exist?('config/clients.yml')
          puts 'ok'
        else
          languages_choice = ask """
No 'config/clients.yml' file found.
To create it, please specify which languages do you want to support when generating API clients.
Available options are: #{LANGUAGES.join(', ')}.
Type them deviding with coma, or type 'all':
          """

          languages_choice = languages_choice.split(',').map(&:strip)
          languages_choice = if languages_choice.include?('all')
            LANGUAGES
          else
            languages_choice.select { |language| LANGUAGES.include?(language) }
          end

          puts "You selected #{languages_choice.join(', ')}"

          # `touch config/clients.yml`
        end
      end

      def find_root_url

      end

      def create_repo
        ask """
Hit <Return> and we'll open a browser to GitHub where you can create a new repository.
When you're done, copy the SSH path from the new repository and return here.
We'll ask you to paste it to us in the next step.
        """
        command = if Gem::Platform.local.os == "linux"
                    "xdg-open"
                  else
                    "open"
                  end
        `#{command} https://github.com/new`

        ssh_path = ask "OK, what was the SSH path? (It should look like `git@github.com:your-account/your-new-repo.git`.)"
        puts green "Setting repository's `origin` remote to `#{ssh_path}`."
        puts `git remote add origin #{ssh_path}`.chomp
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
        return STDIN.gets.strip
      end
    end
  end
end
