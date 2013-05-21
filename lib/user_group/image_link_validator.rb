class ImageLinkValidator < ActiveModel::Validator
    def validate(record)
      unless record.image_link.nil? or record.image_link.blank?
        if record.image_link != SETTING_PROFILE_GRAVATAR_ID
          record.errors[:image_link] << I18n.t("user_groups.users.errors.validation_image_link") if FastImage.type(record.image_link).nil?
        end
      end
    end
end