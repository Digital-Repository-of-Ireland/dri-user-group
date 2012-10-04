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


  #is it ok having this public?
  def toggle_lock
    if self.is_locked 
       self.is_locked = false
    else
      self.is_locked = true
    end
  end
end