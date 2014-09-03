class UserExpectation < ActiveRecord::Base
  attr_accessible :expectation_id, :user_id, :status, :modified_by_id

  belongs_to :expectation
  belongs_to :user

  validates :expectation_id, :uniqueness => {:scope => [ :user_id] }, presence: true
  validates :user_id, presence: true
  validates :status, presence: true
end

class ViewUserExpectation

  def initialize(e)
    @id = e.id
    @expectation_id = e.expectation_id
    @user_id = e.user_id
    @status = e.status
  end

end
