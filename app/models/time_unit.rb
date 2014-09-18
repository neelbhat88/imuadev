class TimeUnit < ActiveRecord::Base
  attr_accessible :name, :organization_id, :roadmap_id

  has_many :milestones, dependent: :destroy
  has_many :users
  has_many :user_tests, dependent: :destroy

  belongs_to :roadmap
end

class ViewTimeUnit
  attr_accessor :id, :name, :milestones

  def initialize(time_unit)
    @id = time_unit.id
    @name = time_unit.name

    @milestones = []
    time_unit.milestones.each do | m |
      @milestones << ViewMilestone.new(m)
    end
  end
end

class DomainTimeUnit

  def initialize(time_unit, options = {})
    @id = time_unit.id
    @name = time_unit.name

    @milestones = options[:milestones]
  end

end
