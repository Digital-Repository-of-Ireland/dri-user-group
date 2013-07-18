FactoryGirl.define do
  ::Kernel.raise

  begin
      UserGroup::User
  rescue NameError
      puts 'has not loaded engine code yet'
  end

  factory :user, :class => UserGroup::User do |u|
    email 'me@me.com'
    password 'password'
  end
end
