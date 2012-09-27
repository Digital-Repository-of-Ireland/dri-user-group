class User < ActiveRecord::Base
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

  def is_admin?
    return true if self.email == "test@example.com"
    return false
  end
end
