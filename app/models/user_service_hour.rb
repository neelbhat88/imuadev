class UserServiceHour < ActiveRecord::Base
  attr_accessible :date, :hours, :service_org_id, :user_id, :time_unit_id

  belongs_to :user

  validates :name, presence: true
  validates :user_id, presence: true
  validates :time_unit_id, presence: true
end
