class Assignment < ActiveRecord::Base
  attr_accessible :assignment_owner_type, :assignment_owner_id, :title, :description, :due_datetime, :organization_id

  has_many :user_assignments, dependent: :destroy

  belongs_to :assignment_owner, polymorphic: true

  validates :assignment_owner_type, presence: true
  validates :assignment_owner_id, presence: true
  validates :title, presence: true
  validates :organization_id, presence: true
end

class AssignmentQuerier < Querier
  def initialize
    super(Assignment)
  end

  def filter_attributes(attributes)
    attributes << :assignment_owner_type unless attributes.include?(:assignment_owner_type)
    attributes << :assignment_owner_id unless attributes.include?(:assignment_owner_id)
    return super(attributes)
  end
end
