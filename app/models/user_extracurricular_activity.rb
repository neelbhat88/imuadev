class UserExtracurricularActivity < ActiveRecord::Base
  attr_accessible :name, :user_id, :description, :time_unit_id

  belongs_to :user
  has_many :user_extracurricular_activity_events, dependent: :destroy

  validates :name, presence: true
  validates :user_id, presence: true
  validates :time_unit_id, presence: true
end
