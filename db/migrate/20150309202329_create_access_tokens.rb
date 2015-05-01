class CreateAccessTokens < ActiveRecord::Migration
  def change
    create_table :access_tokens do |t|
      t.integer :user_id
      t.text :token_value

      t.timestamps
    end

    add_index :access_tokens, :user_id
    add_index :access_tokens, :token_value
  end
end
