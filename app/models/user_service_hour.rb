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

class ViewUserServiceHour

  def initialize(sh)
    @id = sh.id
    @date = sh.date
    @hours = sh.hours
    @user_service_organization_id = sh.user_service_organization_id
    @user_id = sh.user_id
    @time_unit_id = sh.time_unit_id
    @name = sh.name
    @description = sh.description
  end

end

class DomainUserServiceHour

  def initialize(sh)
    @id = sh.id
    @date = sh.date
    @hours = sh.hours
    @user_service_organization_id = sh.user_service_organization_id
    @user_id = sh.user_id
    @time_unit_id = sh.time_unit_id
    @name = sh.name
    @description = sh.description
  end

end
