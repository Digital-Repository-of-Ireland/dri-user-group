class NotPositiveIntegerValidator < ActiveModel::Validator
    def validate(record)
        record.errors[:name] << "cannot be a positive whole number" if record.name =~ /^[0-9]+$/
    end
end

class Group < ActiveRecord::Base
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships, uniq: true

  attr_accessible :name, :description
  
  #DB uniqueness is case insensitive
  before_save { self.name.downcase! }

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 40 }
  validates_with NotPositiveIntegerValidator
  validates :description, presence: true

  def is_locked?
    return true if self.name == "admin"
    return false
  end

  private
    def toggle_lock
      #if self.lock 
      #  self.lock = false
      #else
      #  self.lock = true
      #end
    end
end