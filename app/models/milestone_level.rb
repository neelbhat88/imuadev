class MilestoneLevel < ActiveRecord::Base
  attr_accessible :milestone_id, :value

  belongs_to :milestone
end

class ViewMilestoneLevel
	attr_accessor :value

	def initialize(milestone_level)
		@value = milestone_level.value
	end
	
end
