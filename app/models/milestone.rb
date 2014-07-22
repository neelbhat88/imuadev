class Milestone < ActiveRecord::Base
  attr_accessible :title, :description, :value, :module, :submodule,
                  :importance, :points, :time_unit_id, :icon


  belongs_to :time_unit

  has_many :user_milestones, dependent: :destroy

  validates :title, presence: true
  validates :description, presence: true
  validates :value, presence: true
  validates :module, presence: true
  validates :submodule, presence: true
  validates :importance, presence: true
  validates :points, presence: true
  validates :time_unit_id, presence: true
  validates :icon, presence: true
end

class ViewMilestone
  attr_accessor :id, :description, :importance, :module, :points, :submodule, :title, :icon

  def initialize(milestone)
    @id = milestone.id
    @title = milestone.title
    @description = milestone.description
    @importance = milestone.importance
    @module = milestone.module
    @submodule = milestone.submodule
    @points = milestone.points
    @value = milestone.value
    @icon = milestone.icon
  end

end
