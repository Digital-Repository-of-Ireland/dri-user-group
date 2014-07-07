require 'faker'

FactoryGirl.define do
  sequence :email do
    Faker::Internet.email
  end
end

FactoryGirl.define do
  factory :user, :class => UserGroup::User do |u|
    u.email { FactoryGirl.generate(:email) }
    u.password 'password'
    u.password_confirmation 'password'
    u.first_name Faker::Name.first_name
    u.second_name Faker::Name.last_name
  end

  factory :invalid_user, parent: :user do |u|
    u.email nil 
  end

 factory :admin,  parent: :user do |u|
   after(:create) do |user, evaluator|
     @group = UserGroup::Group.where(name: SETTING_GROUP_ADMIN, description: "admin test group.").first_or_create
     @membership = user.join_group(@group.id)
     @membership.approved_by = user.id
     @membership.save
   end
 end

end
