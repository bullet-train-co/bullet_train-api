# frozen_string_literal: true
require 'rails/tasks'

namespace :bullet_train_api do
  desc 'Generate API clients'
  task :generate_clients, [:all_options] => :environment do |t, arguments|
    ARGV.pop while ARGV.any?

    arguments[:all_options]&.split&.each do |argument|
      ARGV.push(argument)
    end

    # BulletTrain::SuperScaffolding::Runner.new.run
    puts ARGV
  end

  desc 'Publish API clients'
  task :publish_clients do
    # Task goes here
  end
end
