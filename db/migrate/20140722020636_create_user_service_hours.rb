class CreateUserServiceHours < ActiveRecord::Migration
  def change
    create_table :user_service_hours do |t|
      t.integer :service_org_id
      t.decimal :hours
      t.date :date
      t.integer :user_id
      t.integer :time_unit_id

      t.timestamps
    end
  end
end
