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

class UserMilestoneQuerier < Querier
  def initialize(viewAttributes, domainOnlyAttributes = [])
    @column_names = UserMilestone.column_names
    super(viewAttributes, domainOnlyAttributes)
  end

  def self.generate_query()
    return @query = UserMilestone.where(self.conditions).select(self.attributes.all)
  end
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
