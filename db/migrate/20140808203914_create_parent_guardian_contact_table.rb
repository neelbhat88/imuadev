class CreateParentGuardianContactTable < ActiveRecord::Migration
  create_table(:parent_guardian_contacts) do |t|
    t.integer :user_id
    t.string :name
    t.string :relationship
    t.string :email
    t.string :phone

    t.timestamps
  end
end
