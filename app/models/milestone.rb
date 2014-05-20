class Milestone < ActiveRecord::Base
  attr_accessible :description, :importance, :module, :points, :submodule, :time_unit_id, :title

  has_many :milestone_levels
  
  belongs_to :time_unit
end

class ViewMilestone
	attr_accessor :id, :description, :importance, :module, :points, :submodule, :title, :milestone_levels

	def initialize(milestone)
		@id = milestone.id
		@title = milestone.title
		@description = milestone.description
		@importance = milestone.importance
		@module = milestone.module
		@submodule = milestone.submodule
		@points = milestone.points		

		@milestone_levels = []
		milestone.milestone_levels.each do | ml |
			@milestone_levels << ViewMilestoneLevel.new(ml)
		end
				
	end

end
