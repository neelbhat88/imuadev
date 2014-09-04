class AddModifiedByIdToUserExpectations < ActiveRecord::Migration
  def change
    add_column :user_expectations, :modified_by_id, :integer
    add_column :user_expectations, :modified_by_name, :string
  end
end
