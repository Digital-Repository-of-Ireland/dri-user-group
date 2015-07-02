private
def add_group_user(email,first_name,second_name,locale,group)
    user = add_regular_user(email,first_name,second_name,locale)
    group_id = UserGroup::Group.find_by_name(group).id
    add_and_approve_membership(user,group_id)
end

def add_regular_user(email,first_name,second_name,locale)
    raise "No default password set" unless Settings.dri.password.present?
    user = UserGroup::User.where(:email => email).first_or_create(:password => Settings.dri.password, :password_confirmation => Settings.dri.password, :locale => locale, :first_name => first_name, :second_name => second_name)
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
    group_id = UserGroup::Group.find_by_name("om").id
    add_and_approve_membership(UserGroup::User.find_by_email("admin@dri.ie"),group_id)
end

def public_user()
    add_regular_user("user@dri.ie","Public","User","en")
end

def collection_manager()
    add_group_user("manager@dri.ie","Collection","Manager","en","cm")
end

def organisation_manager()
    add_group_user("orgmanager@dri.ie","Organisation","Manager","en","om")
    group_id = UserGroup::Group.find_by_name("cm").id
    add_and_approve_membership(UserGroup::User.find_by_email("orgmanager@dri.ie"),group_id)
end

def groups()
    UserGroup::Group.where(name: "admin").first_or_create(description: "Members of this group have admin permissions", is_locked: true)
    UserGroup::Group.where(name: "registered").first_or_create(description: "Every user account is a member of this group.", is_locked: true)
    UserGroup::Group.where(name: "cm").first_or_create(description: "Members of this group are collection managers", is_locked: true)
    UserGroup::Group.where(name: "om").first_or_create(description: "Members of this group are organisation managers", is_locked: true)
end

groups()
admin_user()
public_user()
collection_manager()
organisation_manager()

puts "Ran seed user_group"
