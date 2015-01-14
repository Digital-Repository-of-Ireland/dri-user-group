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

  s.add_dependency "rails", "~> 4.1.0"
  s.add_dependency "devise", "~> 3.1.0"
  s.add_dependency "devise-i18n-views"
  s.add_dependency "devise-guests", "~> 0.3"
  s.add_dependency "kaminari"
  s.add_dependency "gravatar-ultimate"
  s.add_dependency "fastimage"
  s.add_dependency "omniauth"
  s.add_dependency "omniauth-shibboleth"

  s.add_development_dependency('simplecov')
  s.add_development_dependency('simplecov-rcov')
end
