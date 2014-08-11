class UserTestDateToDateTime < ActiveRecord::Migration
  change_column(:user_tests, :date, :datetime)
end
