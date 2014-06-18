class CreateUserClasses < ActiveRecord::Migration
  def change
    create_table :user_classes do |t|
      t.string :name
      t.string :grade
      t.float :gpa
      t.integer :user_id
      t.integer :time_unit_id

      t.timestamps
    end

    add_index :user_classes, [:user_id, :time_unit_id], :name => 'IDX_UserClass_UserIdTimeUnitId'
  end
end
