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

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"
  s.add_dependency "devise", "~> 2.1.2"
  s.add_dependency "kaminari", "~> 0.14.1"

  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
