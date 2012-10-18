require 'devise'
require 'kaminari'

module UserGroup
  class Engine < ::Rails::Engine
    isolate_namespace UserGroup
  end
end
