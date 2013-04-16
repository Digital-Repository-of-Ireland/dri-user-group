require 'devise'
require 'kaminari'
require 'gravatar-ultimate'
require 'fastimage'

module UserGroup
  class Engine < ::Rails::Engine
    isolate_namespace UserGroup
  end
end
