class AddUserTests < ActiveRecord::Migration
  def change
    create_table :user_tests do |t|
      t.integer :org_test_id
      t.integer :user_id
      t.integer :time_unit_id
      t.date    :date
      t.string  :score
      t.string  :description

      t.timestamps
    end
  end
end
