require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'

  require "rails/application"
  require "rails/mongoid"

  Spork.trap_class_method(Rails::Mongoid, :load_models)
  Spork.trap_method(Rails::Application, :reload_routes!)

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  require File.expand_path("../../config/environment", __FILE__)

  require 'rspec/rails'
  require 'rspec/autorun'

  require 'cancan/matchers'
  require 'capybara/rspec'

  require 'ffaker'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.mock_with :rr

    config.infer_base_class_for_anonymous_controllers = false

    #config.include HelperMethods
    config.include Devise::TestHelpers, :type => :controller
    config.include Mongoid::Matchers

    Capybara.default_driver = :selenium
    Capybara.server_port    = 9999

    require 'database_cleaner'

    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.orm = :mongoid
      DatabaseCleaner.clean
      DatabaseCleaner.start
    end

    config.after(:suite) do
      DatabaseCleaner.clean
    end
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
  Fabrication.clear_definitions
end
