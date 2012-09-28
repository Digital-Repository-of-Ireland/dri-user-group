class Group < ActiveRecord::Base
  attr_accessible :name, :description
  
  #DB uniqueness is case insensitive
  before_save { self.name.downcase! }

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 40 }
  validates :description, presence: true
end
