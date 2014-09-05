class UserClassHistory < ActiveRecord::Base
  attr_accessible :credit_hours, :gpa, :grade, :level, :name, :period,
                  :room, :subject, :time_unit_id, :user_class_id, :user_id,
                  :modified_by_id, :modified_by_name
end
