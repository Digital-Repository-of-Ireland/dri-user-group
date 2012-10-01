class User < ActiveRecord::Base
  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships, uniq: true

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  #attr_accessible :first_name, :second_name, :email, :password, :password_confirmation, :remember_me
  attr_accessible :first_name, :second_name, :email, :password, :password_confirmation

  #Email addresses in database are case insensitive so ensure all the same  
  before_save { self.email.downcase! }

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :second_name, presence: true, length: { maximum: 50 }

  def is_admin?
    return true if self.email == "test@example.com"
    return true if self.email == "fakeemail@fakeemail.fakeemail"
  end

  def member?(group_id)
    return true if self.memberships.find_by_group_id(group_id)
  end

  def join_group(group_id)
      self.memberships.create(group_id: group_id)
  end

  #TODO::(Check fix) What happens if not in group (Crashes)
  def leave_group(group_id)
        membership = self.memberships.find_by_group_id(group_id)
        membership.destroy unless membership.nil?
  end
end
