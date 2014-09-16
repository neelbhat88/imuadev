class Assignment < ActiveRecord::Base
  attr_accessible :user_id, :title, :description, :due_datetime

  belongs_to :user

  has_many :user_assignments, dependent: :destroy

  validates :user_id, presence: true
  validates :title, presence: true
end

class DomainAssignment

  def initialize(assignment, options = {})
    @user_id = assignment.user_id
    @title = assignment.title
    @description = assignment.description
    @due_datetime = assignment.due_datetime

    @user_assignments = options[:user_assignments] unless options[:user_assignments].nil?
  end

end
