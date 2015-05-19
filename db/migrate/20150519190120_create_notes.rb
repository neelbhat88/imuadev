class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.text :message
      t.integer :note_type
      t.datetime :date
      t.decimal :time_spent
      t.integer :created_by
      t.integer :user_id
      t.boolean :is_private

      t.timestamps
    end
  end
end
