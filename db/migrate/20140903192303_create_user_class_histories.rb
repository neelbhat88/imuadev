class CreateUserClassHistories < ActiveRecord::Migration
  def change
    create_table :user_class_histories do |t|
      t.integer :user_class_id
      t.string :name
      t.integer :time_unit_id
      t.string :grade
      t.float :gpa
      t.integer :period
      t.string :room
      t.float :credit_hours
      t.string :level
      t.string :subject
      t.integer :user_id
      t.integer :modified_by_id
      t.string :modified_by_name

      t.timestamps
    end
  end
end
