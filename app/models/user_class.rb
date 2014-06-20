class UserClass < ActiveRecord::Base
  attr_accessible :gpa, :grade, :name, :time_unit_id, :user_id

  belongs_to :user

  validates :name, presence: true
  validates :grade, presence: true
  validates :gpa, presence: true
  validates :time_unit_id, presence: true
  validates :user_id, presence: true
end
