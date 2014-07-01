require 'user_group/image_link_validator'
module UserGroup
  module UserOptions
    extend ActiveSupport::Concern

    included do
      before_save :set_locale
      #attr_accessible :locale, :view_level, :about_me, :image_link

      validates_with ImageLinkValidator
    end

    def set_locale
      self.locale = I18n.locale if self.locale.blank?
    end

    def set_view_level(level)
      int_level = PROFILE_VIEW_LEVELS.key(level)
      self.view_level = int_level.nil? ? 0 : int_level
    end

    def get_view_level
      level =  PROFILE_VIEW_LEVELS[self.view_level]
      return level.nil? ? PROFILE_VIEW_LEVELS[0] : level
    end
  end
end
