class UserExpectation < ActiveRecord::Base
  attr_accessible :expectation_id, :user_id, :status

  belongs_to :expectation
  belongs_to :user

   validates :expectation_id, :uniqueness => {:scope => [ :user_id] }, presence: true
   validates :user_id, presence: true
   validates :status, presence: true
end
