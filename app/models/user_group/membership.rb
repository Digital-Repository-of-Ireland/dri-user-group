module UserGroup
  class Membership < ActiveRecord::Base
    has_paper_trail
    belongs_to :group
    belongs_to :user

    validates :group, presence: true
    validates :user, presence: true

    store :request_form, accessors: %i[name organisation position use], coder: JSON

    # http://thetenelements.blogspot.ie/2011/08/undefined-method-text-for-nilnilclass.html
    validates :group_id, uniqueness: { scope: :user_id }

    def approved?
      true unless approved_by.nil?
    end

    # Hope this is secure
    def approve_membership(admin_id)
      self.approved_by = admin_id
    end
  end
end
