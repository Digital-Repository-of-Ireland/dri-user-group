require 'faker'

FactoryBot.define do
  sequence :name do
    Faker::Lorem.word
  end
end

FactoryBot.define do
  factory :group, class: UserGroup::Group do |g|
    g.name { FactoryBot.generate(:name) }
    g.description { 'a test group' }
    g.is_locked { false }
  end

  factory :invalid_group, parent: :group do |g|
    g.name { nil }
  end

 factory :group_admin, class: UserGroup::Group do |g|
    g.name { SETTING_GROUP_ADMIN }
    g.description { "admin group" }
  end

end
