module UserGroup
  module UserOptions
    extend ActiveSupport::Concern

    included do
      before_save :set_locale
      attr_accessible :locale
    end

    def set_locale
      self.locale = I18n.locale if self.locale.blank?
    end

  end
end
