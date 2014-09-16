class AddCommentToUserExpectation < ActiveRecord::Migration
  def change
    add_column :user_expectations, :comment, :text
    add_column :user_expectation_histories, :comment, :text
  end
end
