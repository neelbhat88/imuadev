class AddTimeUnitIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :time_unit_id, :integer
  end
end
