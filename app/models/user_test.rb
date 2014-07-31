class UserTest < ActiveRecord::Base
  attr_accessible :org_test_id, :user_id, :time_unit_id, :date, :score, :description

  belongs_to :org_test
  belongs_to :user
  belongs_to :time_unit_id

  validates :org_test_id, presence: true
  validates :user_id, presence: true
  validates :time_unit_id, presence: true
  validates :date, presence: true

end
