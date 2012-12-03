namespace :bootstrap do
    desc "Add the default groups"
    task :default_groups => :environment do
        UserGroup::Group.create(name: "admin", description: "Members of this group have admin permissions")
        UserGroup::Group.create(name: "registered", description: "Every user account is a member of this group.")
    end

    desc "Add default users"
    task :default_users => :environment do
        UserGroup::User.create( email: "raymond.noonan@nuim.ie", first_name: "Raymond", second_name: "Noonan", password: "password")
        UserGroup::User.create( email: "damien.gallagher@nuim.ie", first_name: "Damien", second_name: "Gallagher", password: "password")
        UserGroup::User.create( email: "admin@example.com", first_name: "Admin", second_name: "Account", password: "password")
    end

    #Add memberships
    desc "Add users as admins"
    task :default_memberships => :environment do
        group_id = UserGroup::Group.find_by_name("admin").id
        user = UserGroup::User.find_by_email("raymond.noonan@nuim.ie")
        membership = user.join_group(group_id)
        membership.approved_by = user.id
        membership.save

        user = UserGroup::User.find_by_email("damien.gallagher@nuim.ie")
        membership = user.join_group(group_id)
        membership.approved_by = user.id
        membership.save

        user = UserGroup::User.find_by_email("admin@example.com")
        membership = user.join_group(group_id)
        membership.approved_by = user.id
        membership.save

    end
end

task :bootstrap do
  Rake::Task['bootstrap:default_groups'].invoke
  Rake::Task['bootstrap:default_users'].invoke
  Rake::Task['bootstrap:default_memberships'].invoke
end