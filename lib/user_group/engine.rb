require 'devise'

module UserGroup
  class Engine < ::Rails::Engine
    isolate_namespace UserGroup
  end
end
