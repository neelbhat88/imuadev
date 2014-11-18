class AddChangedToColumnToUserExpectaitonHistory < ActiveRecord::Migration
  def change
    add_column :user_expectation_histories, :created_on, :datetime
  end
end
