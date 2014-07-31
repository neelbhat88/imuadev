class AddColumnsToUserClass < ActiveRecord::Migration
  def change
    add_column :user_classes, :period, :integer
    add_column :user_classes, :room, :string
    add_column :user_classes, :credit_hours, :float
    add_column :user_classes, :level, :string
    add_column :user_classes, :subject, :string
  end
end
