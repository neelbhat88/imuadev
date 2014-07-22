class UserServiceHour < ActiveRecord::Base
  attr_accessible :date, :hours, :service_org_id, :user_id
end
