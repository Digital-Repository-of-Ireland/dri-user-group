require 'faker'

FactoryGirl.define do
  factory :user, :class => UserGroup::User do |u|
    u.email Faker::Internet.email
    u.password 'password'
    u.password_confirmation 'password'
    u.first_name Faker::Name.first_name
    u.second_name Faker::Name.last_name
  end

 factory :admin, :class => UserGroup::User do |u|
    u.email 'me@me.com'
    u.password 'password'
    u.password_confirmation 'password'
    u.first_name Faker::Name.first_name
    u.second_name Faker::Name.last_name
  end

end
