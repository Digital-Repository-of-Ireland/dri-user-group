private
def add_admin_user(email,first_name,second_name,locale)
    user = add_regular_user(email,first_name,second_name,locale)
    admin_group_id = UserGroup::Group.find_by_name("admin").id
    add_and_approve_membership(user,admin_group_id)
end

def add_regular_user(email,first_name,second_name,locale)
    user = UserGroup::User.find_or_create_by_email(email, :password => "password", :password_confirmation => "password", :locale => locale, :first_name => first_name, :second_name => second_name) 
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
def admin_users()
    add_admin_user("raymond.noonan@nuim.ie","Raymond","Noonan","en")
    add_admin_user("damien.gallagher@nuim.ie","Damien","Gallagher","en")
    add_admin_user("admin@example.com","Admin","Account","en")
    add_admin_user("jtang@tchpc.tcd.ie","Jimmy","Tang","en")
    add_admin_user("kcassidy@tchpc.tcd.ie","Kathryn","Cassidy","en")
    add_admin_user("skenny@tchpc.tcd.ie","Stuart","Kenny","en")
    add_admin_user("me@me.com","M","E","en")
end

def groups()
    UserGroup::Group.find_or_create_by_name("admin", description: "Members of this group have admin permissions", is_locked: true)
    UserGroup::Group.find_or_create_by_name("registered", description: "Every user account is a member of this group.", is_locked: true)
end

groups()
admin_users()