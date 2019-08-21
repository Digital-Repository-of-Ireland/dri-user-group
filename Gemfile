 source "http://rubygems.org"

# Declare your gem's dependencies in user_group.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# jquery-rails is used by the dummy application
gem "jquery-rails"

gem "sqlite3"
gem "json"

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

group :development, :test do
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-bundler'
  gem 'rb-inotify', require: false
  gem 'rb-fsevent', require: false
  gem 'rb-fchange', require: false
  gem 'rspec-rails'
  gem 'mocha'
  gem 'factory_bot_rails'
  gem 'database_cleaner'
  gem 'faker'
  gem 'ci_reporter_rspec'
  gem 'rspec-legacy_formatters'
  gem 'rails-controller-testing'
  gem 'paper_trail' 
end
