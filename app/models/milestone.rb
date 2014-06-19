class Milestone < ActiveRecord::Base
  attr_accessible :title, :description, :value, :module, :submodule,
                  :importance, :points, :time_unit_id, :is_default, :icon

  belongs_to :time_unit
end

class ViewMilestone
  attr_accessor :id, :description, :importance, :module, :points, :submodule, :title, :is_default, :icon

  def initialize(milestone)
    @id = milestone.id
    @title = milestone.title
    @description = milestone.description
    @importance = milestone.importance
    @module = milestone.module
    @submodule = milestone.submodule
    @points = milestone.points
    @is_default = milestone.is_default
    @value = milestone.value
    @icon = milestone.icon
  end

end
