require 'faker'

FactoryGirl.define do
  factory :group, :class => UserGroup::Group do |g|
    g.name 'test'
    g.description 'a test group'
  end

 factory :group_admin, :class => UserGroup::Group do |g|
    g.name SETTING_GROUP_ADMIN
    g.description "admin group"
  end

end
