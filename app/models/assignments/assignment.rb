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
    if attributes.include?(:user_id) then attributes -= [:user_id]
      attributes << :assignment_owner_id
    end
    attributes << :assignment_owner_type
    return super(attributes)
  end

  def generate_domain(sortBy = [])
    super(sortBy)
    # Domain object manicuring
    @domain.each do |d|
      if d.keys.include?(:assignment_owner_id)
        d[:user_id] = d[:assignment_owner_id]
      end
    end
    return @domain
  end

  def generate_view(conditions = {})
    super(conditions)
    # Final view object manicuring
    @view.each do |v|
      if v.keys.include?(:assignment_owner_id)
        v[:user_id] = v[:assignment_owner_id]
      end
    end
    return @view
  end
end
