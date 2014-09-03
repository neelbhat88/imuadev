class CreateUserExpectationHistories < ActiveRecord::Migration
  def change
    create_table :user_expectation_histories do |t|
      t.integer :expectation_id
      t.integer :user_expectation_id
      t.integer :modified_by_id
      t.integer :user_id
      t.timestamp :updated_at
      t.integer :status
      t.string :title
      t.integer :rank

      t.timestamps
    end
  end
end
