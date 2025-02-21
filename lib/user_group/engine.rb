require 'devise'
require 'kaminari'
require 'rb-gravatar'
require 'fastimage'
require 'omniauth'
require 'omniauth-shibboleth'
require 'blacklight-access_controls'
require 'rails_cloudflare_turnstile'

module UserGroup
  class Engine < ::Rails::Engine
    isolate_namespace UserGroup

    config.generators do |g|
      g.test_framework :rspec, :fixture => true
      g.fixture_replacement :factory_bot, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end

  end
end
