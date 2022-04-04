# frozen_string_literal: true
require 'rails/tasks'

namespace :bullet_train_api do
  desc 'Generate API clients'
  task :generate_clients => :environment do |t, arguments|
    BulletTrain::Api::Clients.new(Rails.application.class.module_parent_name).generate
  end

  desc 'Publish API clients'
  task :publish_clients do
    # Task goes here
  end
end
