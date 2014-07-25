class UserExtracurricularActivity < ActiveRecord::Base
  attr_accessible :name, :user_id, :position, :time_unit_id

  belongs_to :user

  validates :name, presence: true
  validates :user_id, presence: true
  validates :time_unit_id, presence: true
end
