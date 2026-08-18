class ImageLinkValidator < ActiveModel::Validator
  def validate(record)
    return if record.image_link.nil? or record.image_link.blank?
    return unless record.image_link != SETTING_PROFILE_GRAVATAR_ID

    return unless FastImage.type(record.image_link).nil?

    record.errors[:image_link] << I18n.t('user_groups.users.errors.validation_image_link')
  end
end
