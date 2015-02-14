class Assignment < ActiveRecord::Base
  attr_accessible :type, :type_id, :title, :description, :due_datetime, :organization_id

  has_many :user_assignments, dependent: :destroy

  validates :type, presence: true
  validates :type_id, presence: true
  validates :title, presence: true
  validates :organization_id, presence: true
end

class AssignmentQuerier < Querier
  def initialize
    super(Assignment)
  end

  def filter_attributes(attributes)
    if attributes.include?(:user_id) then attributes -= [:user_id]
      attributes << :context_id
    end
    attributes << :context
    return super(attributes)
  end

  def generate_domain(sortBy = [])
    super(sortBy)
    # Domain object manicuring
    @domain.each do |d|
      if d.keys.include?(:context_id)
        d[:user_id] = d[:context_id]
      end
    end
    return @domain
  end

  def generate_view(conditions = {})
    super(conditions)
    # Final view object manicuring
    @view.each do |v|
      if v.keys.include?(:context_id)
        v[:user_id] = v[:context_id]
      end
    end
    return @view
  end
end
