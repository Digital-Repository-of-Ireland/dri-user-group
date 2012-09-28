class Group < ActiveRecord::Base
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships, uniq: true

  attr_accessible :name, :description
  
  #DB uniqueness is case insensitive
  before_save { self.name.downcase! }

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 40 }
  validates :description, presence: true

  def member?(user_id)
    return true if self.memberships.find_by_user_id(user_id)
  end

  #What happens if already member?
  def join_group(user_id)
      self.memberships.create(user_id: user_id)
  end

  #What happens if not in group (Crashes)
  def leave_group(user_id)
        self.memberships.find_by_user_id(user_id).destroy
  end
end
