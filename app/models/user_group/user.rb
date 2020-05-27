module UserGroup
  class UserGroup::User < ActiveRecord::Base
    has_paper_trail ignore: [:updated_at, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :sign_in_count]

    include Blacklight::AccessControls::User

    include UserGroup::UserSecurity
    include UserGroup::UserOptions

    scope :by_letter, ->(initial) { where("second_name LIKE \'#{initial}%\'").order(:second_name) }
    scope :search, ->(search) { where("email LIKE :search OR first_name LIKE :search OR second_name LIKE :search", { search: "%#{search}%" }) }

    def self.create_for_shibboleth(access_token)
      u = UserGroup::User.new
      u.apply_omniauth(access_token)
      u.skip_confirmation!
      u
    end

  end
end
