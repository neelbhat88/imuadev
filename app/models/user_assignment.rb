class UserAssignment < ActiveRecord::Base
  attr_accessible :assignment_id, :user_id, :status

  belongs_to :assignment
  belongs_to :user

  validates :assignment_id, :uniqueness => {:scope => [ :user_id] }, presence: true
  validates :user_id, presence: true
  validates :status, presence: true
end

class DomainUserAssignment

  def initialize(user_assignment, options = {})
    @assignment_id = user_assignment.assignment_id
    @user_id = user_assignment.user_id
    @status = user_assignment.status

    @assignment = options[:assignment] unless options[:assignment].nil?
  end

end
