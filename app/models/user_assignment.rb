class UserAssignment < ActiveRecord::Base
  attr_accessible :assignment_id, :user_id, :status

  belongs_to :assignment
  belongs_to :user

  validates :assignment_id, :uniqueness => {:scope => [ :user_id] }, presence: true
  validates :user_id, presence: true
  validates :status, presence: true
end
