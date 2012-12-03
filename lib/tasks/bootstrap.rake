namespace :bootstrap do
    desc "Add the default groups"
    task :default_groups => :environment do
        UserGroup::Group.create(name: "admin", description: "Members of this group have admin permissions")
        UserGroup::Group.create(name: "registered", description: "Every user account is a member of this group.")
    end

    desc "Add default users"
    task :default_users => :environment do
        add_admin_user("raymond.noonan@nuim.ie","Raymond","Noonan")
        add_admin_user("damien.gallagher@nuim.ie","Damien","Gallagher")
        add_admin_user("admin@example.com","Admin","Account")
    end
end

task :bootstrap do
  Rake::Task['bootstrap:default_groups'].invoke
  Rake::Task['bootstrap:default_users'].invoke
end


private

def add_admin_user(email,first_name,second_name)
    user = add_regular_user(email,first_name,second_name)
    admin_group_id = UserGroup::Group.find_by_name("admin").id
    add_and_approve_membership(user,admin_group_id)
end

def add_regular_user(email,first_name,second_name)
    user = UserGroup::User.create( email: email, first_name: first_name, second_name: second_name, password: "password")
    registered_group_id = UserGroup::Group.find_by_name("registered").id
    add_and_approve_membership(user,registered_group_id)
    return user
end

def add_and_approve_membership(user,group_id)
    membership = user.join_group(group_id)
    membership.approved_by = user.id
    membership.save
end