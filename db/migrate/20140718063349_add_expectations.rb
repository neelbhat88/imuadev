class AddExpectations < ActiveRecord::Migration
  def change
    create_table :expectations do |t|
      t.integer :organization_id
      t.string  :title
      t.string  :description
      t.integer :rank

      t.timestamps
    end
  end
end
