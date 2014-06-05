class Roadmap < ActiveRecord::Base
  attr_accessible :description, :name, :organization_id

  has_many :time_units, dependent: :destroy
end

class ViewRoadmap
  attr_accessor :id, :name, :description, :organization_id, :time_units

  def initialize(roadmap)
    @id = roadmap.id
    @name = roadmap.name
    @description = roadmap.description
    @organization_id = roadmap.organization_id

    @time_units = []
    roadmap.time_units.each do | t |
      @time_units << ViewTimeUnit.new(t)
    end

  end
end
