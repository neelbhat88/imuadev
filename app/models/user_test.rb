class UserTest < ActiveRecord::Base
  attr_accessible :org_test_id, :user_id, :time_unit_id, :date, :score, :description

  belongs_to :org_test
  belongs_to :user
  belongs_to :time_unit

  validates :org_test_id, presence: true
  validates :user_id, presence: true
  validates :time_unit_id, presence: true
  validates :date, presence: true

end

class ViewUserTest

  def initialize(ut)
    @id = ut.id
    @org_test_id = ut.org_test_id
    @user_id = ut.user_id
    @time_unit_id = ut.time_unit_id
    @date = ut.date
    @score = ut.score
    @description = ut.description
  end

end
