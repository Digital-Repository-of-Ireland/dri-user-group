$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "user_group/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "user_group"
  s.version     = UserGroup::VERSION
  s.authors     = ["Raymond Noonan"]
  s.email       = ["raymond.noonan@nuim.ie"]
  s.homepage    = "http://www.dri.ie"
  s.summary     = "A Group based management system for access controls"
  s.description = "UserGroup provides through devise user accounts and group management to a rails application."

  s.files = Dir["{app,config,db,lib}/**/**/*"] + ["Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]
  s.require_path = 'lib'

  s.add_dependency "rails", "~> 5"
  s.add_dependency "devise"
  s.add_dependency "devise-i18n-views"
  s.add_dependency "devise-guests", "~> 0.3"
  s.add_dependency "kaminari"
  s.add_dependency "rb-gravatar"
  s.add_dependency "fastimage"
  s.add_dependency "omniauth", "~> 1.9.1"
  s.add_dependency "omniauth-shibboleth"
  s.add_dependency "paper_trail"
  s.add_dependency "blacklight-access_controls"

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'ci_reporter_rspec'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'rails-controller-testing'
end

