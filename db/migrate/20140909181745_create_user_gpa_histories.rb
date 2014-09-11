class CreateUserGpaHistories < ActiveRecord::Migration
  def change
    create_table :user_gpa_histories do |t|
      t.integer :user_gpa_id
      t.integer :user_id
      t.float :core_unweighted
      t.float :core_weighted
      t.float :regular_weighted
      t.float :regular_unweighted
      t.integer :time_unit_id

      t.timestamps
    end
  end
end
