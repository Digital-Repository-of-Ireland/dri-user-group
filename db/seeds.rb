private
def add_group_user(email,first_name,second_name,locale,group)
    user = add_regular_user(email,first_name,second_name,locale)
    group_id = UserGroup::Group.find_by_name(group).id
    add_and_approve_membership(user,group_id)
end

def add_regular_user(email,first_name,second_name,locale)
    user = UserGroup::User.find_or_create_by(email: email, :password => "J3xG9ABC", :password_confirmation => "J3xG9ABC", :locale => locale, :first_name => first_name, :second_name => second_name)
    user.confirm!
    registered_group_id = UserGroup::Group.find_by_name("registered").id
    add_and_approve_membership(user,registered_group_id)
    return user
end

def add_and_approve_membership(user,group_id)
    membership = user.join_group(group_id)
    membership.approved_by = user.id
    membership.save
end

public
def admin_user()
    add_group_user("admin@dri.ie","Admin","Admin","en","admin")
    group_id = UserGroup::Group.find_by_name("cm").id
    add_and_approve_membership(UserGroup::User.find_by_email("admin@dri.ie"),group_id)
end

def public_user()
    add_regular_user("user@dri.ie","Public","User","en")
end

def collection_manager()
    add_group_user("manager@dri.ie","Collection","Manager","en","cm")
end

def groups()
    UserGroup::Group.find_or_create_by(name: "admin", description: "Members of this group have admin permissions", is_locked: true)
    UserGroup::Group.find_or_create_by(name: "registered", description: "Every user account is a member of this group.", is_locked: true)
    UserGroup::Group.find_or_create_by(name: "cm", description: "Members of this group are collection managers", is_locked: true)
end

groups()
admin_user()
public_user()
collection_manager()

puts "Ran seed user_group"
