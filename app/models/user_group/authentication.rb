module UserGroup
  class UserGroup::Authentication < ActiveRecord::Base
    belongs_to :user
  end
end
