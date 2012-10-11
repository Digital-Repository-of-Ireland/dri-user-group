namespace :bootstrap do
    desc "Add default users"
    task :default_user => :environment do 
        UserGroup::User.create( email: "raymond.noonan@nuim.ie", first_name: "Raymond", second_name: "Noonan", password: "password")
        UserGroup::User.create( email: "damien.gallagher@nuim.ie", first_name: "Damien", second_name: "Gallagher", password: "password")
        UserGroup::User.create( email: "admin@example.com", first_name: "Admin", second_name: "", password: "password")
    end

    desc "Add the default groups"
    task :default_groups => :environment do
        UserGroup::Group.create(name: "admin", description: "Members of this group have admin permissions")
    end

    #Add memberships
end