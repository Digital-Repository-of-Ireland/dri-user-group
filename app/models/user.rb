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

  def full_name
    return self.first_name + " " + self.second_name
  end
  
  def is_admin?
    group = Group.find_by_name("admin")
    return true if !group.nil? && self.member?(group.id)
  end

  def member?(group_id)
    membership = self.memberships.find_by_group_id(group_id)
    return true if !membership.nil? && membership.approved?
  end

  def join_group(group_id_or_name)
      group_id = group_id_or_name
      if(not_positive_integer?(group_id_or_name))
        group = Group.find_by_name(group_id_or_name.downcase)
        group_id = group.id unless group.nil?
      end 
      membership = self.memberships.create(group_id: group_id)
  end

  def leave_group(group_id_or_name)
      group_id = group_id_or_name
      if(not_positive_integer?(group_id_or_name))
          group = self.groups.find_by_name(group_id_or_name.downcase)
          group_id = group.id unless group.nil?
      end
      membership = self.memberships.find_by_group_id(group_id)
      membership.destroy unless membership.nil?
  end

  private
    def not_positive_integer?(string)
      return true unless string =~ /^[0-9]+$/
    end
end
