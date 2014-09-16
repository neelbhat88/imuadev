class UserClass < ActiveRecord::Base
  attr_accessible :gpa, :grade, :name, :time_unit_id, :user_id,
                  :period, :room, :credit_hours, :level, :subject,
                  :modified_by_id, :modified_by_name

  belongs_to :user

  validates :name, presence: true
  validates :grade, presence: true
  validates :gpa, presence: true
  validates :time_unit_id, presence: true
  validates :user_id, presence: true
end

class ViewUserClass

  def initialize(uc)
    @id = uc.id
    @gpa = uc.gpa
    @grade = uc.grade
    @name = uc.name
    @time_unit_id = uc.time_unit_id
    @user_id = uc.user_id
    @period = uc.period
    @room = uc.room
    @credit_hours = uc.credit_hours
    @level = uc.level
    @subject = uc.subject
    @modified_by_id = uc.modified_by_id
    @modified_by_name = uc.modified_by_name
  end

end

class DomainUserClass

  def initialize(uc)
    @id = uc.id
    @gpa = uc.gpa
    @grade = uc.grade
    @name = uc.name
    @time_unit_id = uc.time_unit_id
    @user_id = uc.user_id
    @period = uc.period
    @room = uc.room
    @credit_hours = uc.credit_hours
    @level = uc.level
    @subject = uc.subject
    @modified_by_id = uc.modified_by_id
    @modified_by_name = uc.modified_by_name
  end

end
