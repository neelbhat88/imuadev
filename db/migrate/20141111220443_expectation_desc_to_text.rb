class ExpectationDescToText < ActiveRecord::Migration
  def up
    change_column :expectations, :title, :text
    change_column :expectations, :description, :text
  end

  def down
    change_column :expectations, :title, :string
    change_column :expectations, :description, :string
  end
end
