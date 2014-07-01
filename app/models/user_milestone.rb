class UserMilestone < ActiveRecord::Base
  attr_accessible :milestone_id, :module, :submodule, :time_unit_id, :user_id

  validates :milestone_id, presence: true
  validates :module, presence: true
  validates :submodule, presence: true
  validates :time_unit_id, presence: true
  validates :user_id, presence: true  
end
