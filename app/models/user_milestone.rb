class UserMilestone < ActiveRecord::Base
  attr_accessible :milestone_id, :module, :submodule, :time_unit_id, :user_id

  belongs_to :milestone
  belongs_to :user
  belongs_to :time_unit

  validates :milestone_id, :uniqueness => { :scope => :user_id }, presence: true
  validates :module, presence: true
  validates :submodule, presence: true
  validates :time_unit_id, presence: true
  validates :user_id, presence: true
end

class ViewUserMilestone

  def initialize(um)
    @id = um.id
    @milestone_id = um.milestone_id
    @module = um.module
    @submodule = um.submodule
    @time_unit_id = um.time_unit_id
    @user_id = um.user_id
  end

end

class DomainUserMilestone

  def initialize(um)
    @id = um.id
    @milestone_id = um.milestone_id
    @module = um.module
    @submodule = um.submodule
    @time_unit_id = um.time_unit_id
    @user_id = um.user_id
  end

end
