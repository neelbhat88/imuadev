class UserAssignment < ActiveRecord::Base
  include PublicActivity::Model
  # Set Activity's owner to current_user by default
  tracked owner: Proc.new{ |controller, model| controller.current_user }, recipient: :user
  acts_as_commentable

  attr_accessible :assignment_id, :user_id, :status

  belongs_to :assignment
  belongs_to :user

  validates :assignment_id, :uniqueness => {:scope => [ :user_id] }, presence: true
  validates :user_id, presence: true
  validates :status, presence: true
end

class DomainUserAssignment

  def initialize(options = {})

    user_assignment = options[:user_assignment]
    unless user_assignment.nil?
      @assignment_id = user_assignment.assignment_id
      @user_id = user_assignment.user_id
      @status = user_assignment.status
    end

    @assignment = options[:assignment] unless options[:assignment].nil?
  end

end
