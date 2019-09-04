module UserGroup
  class NotPositiveIntegerValidator < ActiveModel::Validator
    def validate(record)
      record.errors[:name] << I18n.t("user_groups.groups.errors.validation") if record.name =~ /^[0-9]+$/
    end
  end

  class Group < ActiveRecord::Base
    has_many :memberships, dependent: :destroy
    has_many :users, -> { distinct }, through: :memberships

    #DB uniqueness is case insensitive
    before_save { self.name.downcase! }

    validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 40 }
    validates_with NotPositiveIntegerValidator
    validates :description, presence: true


    #is it ok having this public?
    def toggle_lock
      if self.is_locked
        self.is_locked = false
      else
        self.is_locked = true
      end
    end

    def full_memberships
      self.memberships.where("approved_by IS NOT NULL")
    end

    def pending_memberships
      self.memberships.where(approved_by: nil)
    end

    def self.search(search)
      if search
        where("name LIKE ?", "%#{search}%")
      else
        all
      end
    end
  end
end
