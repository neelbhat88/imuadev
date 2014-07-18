class Relationship < ActiveRecord::Base
  attr_accessible :assigned_to_id, :user_id

  belongs_to :user

  validates :assigned_to_id, :uniqueness => {:scope => :user_id }, presence: true
  validates :user_id, presence: true
end
