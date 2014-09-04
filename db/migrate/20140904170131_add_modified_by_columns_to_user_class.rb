class AddModifiedByColumnsToUserClass < ActiveRecord::Migration
  def change
    add_column :user_classes, :modified_by_id, :integer
    add_column :user_classes, :modified_by_name, :string
  end
end
