FactoryGirl.define do
  factory :user, :class => User do |u|
    email 'me@me.com'
    password 'password'
  end
end
