class Membership < ActiveRecord::Base
  attr_accessible :created_at, :group_id, :user_id
  belongs_to :group
  belongs_to :user

  validates :group, presence: true
  validates :user, presence: true

  #http://thetenelements.blogspot.ie/2011/08/undefined-method-text-for-nilnilclass.html
  validates :group_id, uniqueness: {scope: :user_id}
end
