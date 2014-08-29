class Assignment < ActiveRecord::Base
  attr_accessible :user_id, :title, :description, :due_datetime

  belongs_to :user

  has_many :user_assignments

  validates :user_id, presence: true
  validates :title, presence: true
end
