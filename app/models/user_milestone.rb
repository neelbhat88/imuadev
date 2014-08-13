class UserMilestone < ActiveRecord::Base
  attr_accessible :org_milestone_id, :user_id
  attr_accessible :module, :submodule, :time_unit_id

  belongs_to :org_milestone
  belongs_to :user
  belongs_to :time_unit

  validates :org_milestone_id, :uniqueness => {:scope => [ :user_id ] }, presence: true
  validates :module, presence: true
  validates :submodule, presence: true
  validates :time_unit_id, presence: true
  validates :user_id, presence: true
end
