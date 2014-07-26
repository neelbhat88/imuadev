class UserExtracurricularActivityDetail < ActiveRecord::Base
  attr_accessible :description, :extracurricular_activity_id, :user_id,
    :time_unit_id

  belongs_to :user

  validates :description, presence: true
  validates :extracurricular_activity_id, presence: true
  validates :user_id, presence: true
  validates :time_unit_id, presence: true
end
