class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.integer :qnum
      t.string :text
      t.timestamps
    end
  end
end
