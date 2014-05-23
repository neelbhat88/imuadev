class Milestone < ActiveRecord::Base
  attr_accessible :description, :importance, :module, :points, :submodule, :time_unit_id, :title, :is_default

  has_many :milestone_levels

  belongs_to :time_unit
end

class ViewMilestone
  attr_accessor :id, :description, :importance, :module, :points, :submodule, :title, :milestone_levels, :is_default

  def initialize(milestone)
    @id = milestone.id
    @title = milestone.title
    @description = milestone.description
    @importance = milestone.importance
    @module = milestone.module
    @submodule = milestone.submodule
    @points = milestone.points
    @is_default = milestone.is_default

    @milestone_levels = []
    milestone.milestone_levels.each do | ml |
      @milestone_levels << ViewMilestoneLevel.new(ml)
    end

  end

end
