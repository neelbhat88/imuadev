class TimeUnit < ActiveRecord::Base
  attr_accessible :name, :organization_id, :roadmap_id

  has_many :org_milestones, dependent: :destroy
  has_many :users
  has_many :user_tests, dependent: :destroy

  belongs_to :roadmap
end

class ViewTimeUnit
  attr_accessor :id, :name, :org_milestones

  def initialize(time_unit)
    @id = time_unit.id
    @name = time_unit.name

    @org_milestones = []
    time_unit.org_milestones.each do | m |
      @org_milestones << ViewOrgMilestone.new(m)
    end
  end
end
