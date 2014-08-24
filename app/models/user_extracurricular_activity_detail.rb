class UserExtracurricularActivityDetail < ActiveRecord::Base
  attr_accessible :description, :user_extracurricular_activity_id, :user_id,
    :time_unit_id, :leadership, :name

  belongs_to :user
  belongs_to :user_extracurricular_activity

  validates :user_extracurricular_activity_id, presence: true
  validates :user_id, presence: true
  validates :time_unit_id, presence: true
end