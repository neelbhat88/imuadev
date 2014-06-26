class ImuaMilestone
  attr_accessor :title, :description, :value, :module, :submodule,
                  :importance, :points, :time_unit_id, :icon

  def initialize
    @module = ""
    @submodule = ""
    @title = "n/a"
    @description = "n/a"
    @value = "n/a"
    @icon = "n/a"
    @time_unit_id = nil
    @importance = 1
    @points = 10
    @icon = ""
  end

  def valid?
    return true
  end
end
