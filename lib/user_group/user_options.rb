module UserGroup
  module UserOptions
    extend ActiveSupport::Concern

    included do
      attr_accessible :locale
    end

    module InstanceMethods
      def placeholder
        return "placeholder"
      end
    end

  end
end
