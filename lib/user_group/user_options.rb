module UserGroup
  class ImageLinkValidator < ActiveModel::Validator
    def validate(record)
      unless record.image_link.nil?
        if record.image_link != SETTING_PROFILE_GRAVATAR_ID
          record.errors[:image_link] << I18n.t("user_groups.users.errors.validation_image_link") if FastImage.type(record.image_link).nil?
        end
      end
    end 
  end

  module UserOptions
    extend ActiveSupport::Concern

    included do
      before_save :set_locale
      attr_accessible :locale, :view_level, :about_me, :image_link

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
