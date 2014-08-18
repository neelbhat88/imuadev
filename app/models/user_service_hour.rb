class UserServiceHour < ActiveRecord::Base
  attr_accessible :date, :hours, :user_service_organization_id, :user_id, :time_unit_id,
    :name, :description

  belongs_to :user
  belongs_to :user_service_organization

  validates :user_id, presence: true
  validates :user_service_organization_id, presence: true
  validates :time_unit_id, presence: true
  validates :date, presence: true
  validates :hours, presence: true
end
