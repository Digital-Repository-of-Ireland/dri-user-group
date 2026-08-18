module UserGroup
  class UserGroup::User < ActiveRecord::Base
    has_paper_trail ignore: %i[updated_at current_sign_in_at last_sign_in_at current_sign_in_ip last_sign_in_ip
                               sign_in_count]

    include Blacklight::User
    include Blacklight::AccessControls::User

    include UserGroup::UserSecurity
    include UserGroup::UserOptions

    scope :by_letter, ->(initial) { where("second_name LIKE \'#{initial}%\'").order(:second_name) }
    scope :search, lambda { |search|
      where('email LIKE :search OR first_name LIKE :search OR second_name LIKE :search', { search: "%#{search}%" })
    }

    def self.create_for_shibboleth(access_token)
      u = UserGroup::User.new
      u.apply_omniauth(access_token)
      u.skip_confirmation!
      u
    end

    def self.included(klass)
      # Other modules to auto-include
      klass.extend(ClassMethods)
    end

    def to_s
      email
    end

    module ClassMethods
      # This method should find User objects using the user_key you've chosen.
      # By default, uses the unique identifier specified in by devise authentication_keys (ie. find_by_id, or find_by_email).
      # You must have that find method implemented on your user class, or must override find_by_user_key
      def find_by_user_key(key)
        send("find_by_#{Devise.authentication_keys.first}".to_sym, key)
      end
    end
  end
end
