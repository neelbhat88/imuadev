class MilestoneLevel < ActiveRecord::Base
  attr_accessible :milestone_id, :value, :title

  belongs_to :milestone
end

class ViewMilestoneLevel
  attr_accessor :value, :title, :id

  def initialize(milestone_level)
    @id = milestone_level.id
    @value = milestone_level.value
    @title = milestone_level.title
  end

end
