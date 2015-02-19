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
    # Assignments should always return these properties
    attributes << :assignment_owner_type unless attributes.include?(:assignment_owner_type)
    attributes << :assignment_owner_id unless attributes.include?(:assignment_owner_id)
    return super(attributes)
  end

  # Bad hack to support the sub_querier's method for nesting
  def sub_querier_keys()
    ret = @columnNames
    ret << :user_id
    ret << :milestone_id
    return ret
  end

  def generate_domain(sortBy = [])
    # Bad hack to support the sub_querier's method for nesting
    super(sortBy << :assignment_owner_id)
    # Domain object manicuring
    @domain.each do |d|
      # Bad hack to support the sub_querier's method for nesting
      if d.keys.include?(:assignment_owner_type)
        case d[:assignment_owner_type]
        when "User"
          d[:user_id] = d[:assignment_owner_id]
        when "Milestone"
          d[:milestone_id] = d[:assignment_owner_id]
        end
      end
    end
    return @domain
  end
end
