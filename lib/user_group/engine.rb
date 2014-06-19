require 'devise'
require 'kaminari'
require 'gravatar-ultimate'
require 'fastimage'
require 'omniauth'
require 'omniauth-shibboleth'

module UserGroup
  class Engine < ::Rails::Engine
    isolate_namespace UserGroup

    config.generators do |g|
      g.test_framework :rspec, :fixture => true
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end

  end
end
