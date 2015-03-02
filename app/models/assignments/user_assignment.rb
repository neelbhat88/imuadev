class UserAssignment < ActiveRecord::Base
  acts_as_commentable

  attr_accessible :assignment_id, :user_id, :status

  belongs_to :assignment
  belongs_to :user

  validates :assignment_id, :uniqueness => {:scope => [ :user_id] }, presence: true
  validates :user_id, presence: true
  validates :status, presence: true
end
