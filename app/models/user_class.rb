class UserClass < ActiveRecord::Base
  attr_accessible :gpa, :grade, :name, :time_unit_id, :user_id

  belongs_to :user
end
