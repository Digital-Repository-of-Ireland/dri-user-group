# This file is copied to spec/ when you run 'rails generate rspec:install'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'app', 'models'))

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/features/'
end

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../test_app/config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/expectations'
require 'user_group'
require 'factory_bot_rails'
require 'database_cleaner'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
#Dir[Rails.root.join("../../spec/factories/*.rb")].each { |f| require f }

#FactoryBot.find_definitions

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.infer_spec_type_from_file_location!

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
  config.before(:each, type: "controller") { @routes = UserGroup::Engine.routes }
  config.include Devise::Test::ControllerHelpers, type: :controller

  config.include Rails.application.routes.url_helpers

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end
  config.before(:each) do
    DatabaseCleaner.start
  end
  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  #config.include FactoryBot::Syntax::Methods

  #config.before(:suite) do
  #  FactoryBot.find_definitions
  #end
end

#module FactoryBot
# def self.find_or_create(handle, by=:email)
#   tmpl = FactoryBot.build(handle)
#   tmpl.class.send("find_by_#{by}".to_sym, tmpl.send(by)) || FactoryBot.create(handle)
# end
#end
