class CreateUserServiceOrgs < ActiveRecord::Migration
  def change
    create_table :user_service_orgs do |t|
      t.string :name
      t.integer :user_id
      t.integer :time_unit_id

      t.timestamps
    end
  end
end
