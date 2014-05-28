module UserGroup
  module UserSecurity
    extend ActiveSupport::Concern
    #Adding ActiveSupport::Concern looks for modules named ClassMethods and InstanceMethods and bootstraps them
    #InstanceMethods is now depricated
    #Also provides the included which will run when class is included

    included do
      has_many :memberships, dependent: :destroy
      has_many :groups, through: :memberships, uniq: true


      #Database Authenticatable: encrypts and stores a password in the database to validate the authenticity of a user while signing in. The authentication can be done both through POST requests or HTTP Basic Authentication.
      #Token Authenticatable: signs in a user based on an authentication token (also known as "single access token"). The token can be given both through query string or HTTP Basic Authentication.
      #Omniauthable: adds Omniauth (https://github.com/intridea/omniauth) support;
      #Confirmable: sends emails with confirmation instructions and verifies whether an account is already confirmed during sign in.
      #Recoverable: resets the user password and sends reset instructions.
      #Registerable: handles signing up users through a registration process, also allowing them to edit and destroy their account.
      #Rememberable: manages generating and clearing a token for remembering the user from a saved cookie.
      #Trackable: tracks sign in count, timestamps and IP address.
      #Timeoutable: expires sessions that have no activity in a specified period of time.
      #Validatable: provides validations of email and password. It's optional and can be customized, so you're able to define your own validations.
      #Lockable: locks an account after a specified number of failed sign-in attempts. Can unlock via email or after a specified time period.
      devise :confirmable, :database_authenticatable, :token_authenticatable,
        :recoverable, :rememberable, :trackable, :omniauthable, :omniauth_providers => [:shibboleth]

      attr_accessible :first_name, :second_name, :email, :password, :password_confirmation, :provider, :uid, :remember_me, :token_creation_date

      #Email addresses in database are case insensitive so ensure all the same
      before_save { self.email.downcase! }

      validates :email, presence: true, uniqueness: { case_sensitive: false }
      validates :first_name, presence: true, length: { maximum: 50 }
      validates :second_name, presence: true, length: { maximum: 50 }
      validates :password_confirmation, presence: true, :on => :create, if: :password_required?
      validates :password, presence: true, confirmation: true, length: {minimum: 6}, :on => :create, if: :password_required?
    end

    def to_s
      return "UserGroup:: "+ self.full_name
    end

    def full_name
      return self.first_name.to_s + " " + self.second_name.to_s
    end

    def is_admin?
      group = Group.find_by_name(SETTING_GROUP_ADMIN)
      return true if !group.nil? && self.member?(group.id)
    end

    def is_cm?
      group = Group.find_by_name(SETTING_GROUP_CM)
      return true if !group.nil? && self.member?(group.id)
    end

    def is_registered?
      group = Group.find_by_name(SETTING_GROUP_DEFAULT)
      return true if !group.nil? && self.member?(group.id)
    end

    def is_public?
      group = Group.find_by_name(SETTING_GROUP_PUBLIC)
      return true if !group.nil? && self.member?(group.id)
    end

    def member?(group_id)
      membership = self.memberships.find_by_group_id(group_id)
      return true if !membership.nil? && membership.approved?
    end

    def pending_member?(group_id)
      membership = self.memberships.find_by_group_id(group_id)
      return true if !membership.nil? && !membership.approved?
    end


    def join_group(group_id)
      membership = self.memberships.create(group_id: group_id)
    end

    def leave_group(group_id)
      membership = self.memberships.find_by_group_id(group_id)
      membership.destroy unless membership.nil?
    end

    def create_token
      self.reset_authentication_token!
      self.token_creation_date = DateTime.current
    end

    def destroy_token
      self.authentication_token = nil
      self.token_creation_date = nil
    end

    def token_expired?
      return true if self.authentication_token.blank? or (SETTING_PROFILE_TOKEN_EXPIRY_DAYS!=0 and (Date.today > token_age_allowed))
      return false
    end

    def token_age_allowed
      self.token_creation_date.to_date+SETTING_PROFILE_TOKEN_EXPIRY_DAYS
    end

    #Shared with group.rb [move]
    #be careful you dont do = 1 http://stackoverflow.com/questions/4252349/rail-3-where-condition-using-not-null
    def full_memberships
      self.memberships.where("approved_by IS NOT NULL")
    end

    def pending_memberships
      self.memberships.where(approved_by: nil)
    end

    def applicable_policy?(policy)
      case policy
      when SETTING_POLICY_COLLECTION_MANAGER
        #Policy A user is considered a collection manager if they are in the group cm
        #Note: A user can be a local collection manager (If they are down as a manager on the DO/Collection) but this
        #does not grant them collectionmanager pemissions in the system. e.g. Ability to create a collection
        group = UserGroup::Group.find_by_name(SETTING_GROUP_CM)
        return false if group.nil?
        return true if self.member?(group.id)
      when SETTING_POLICY_ADMIN
        group = UserGroup::Group.find_by_name(SETTING_GROUP_ADMIN)
        return false if group.nil?
        return true if self.member?(group.id)
      else
        logger.debug("Applicable policy- no policy applies")
        return false
      end
    end

    def apply_omniauth(omniauth)
      logger.debug("Omniauth #{omniauth.inspect.to_yaml}")
      self.provider = omniauth['provider']  
      self.uid = omniauth['uid']
      self.email = omniauth['info']['email'] if email.blank?
      self.first_name = omniauth['info']['given_name'] if first_name.blank?
      self.second_name = omniauth['info']['last_name'] if second_name.blank?
    end

    def password_required?
      self.provider.blank?
    end

  end
end
