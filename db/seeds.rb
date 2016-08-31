# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Create super admin
User.create(email: "superadmin@gmail.com", first_name: "Super", last_name: "Admin", role: 0, password: "myimua", status: 0, organization_id: 0)

# Create AppVersion
AppVersion.create(version_number: 1)
