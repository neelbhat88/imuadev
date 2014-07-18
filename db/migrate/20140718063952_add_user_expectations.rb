class AddUserExpectations < ActiveRecord::Migration
  def change
    create_table :user_expectations do |t|
      t.integer :expectation_id
      t.integer :user_id
      t.integer :status

      t.timestamps
    end
  end
end
