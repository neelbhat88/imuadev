class UserExpectationHistory < ActiveRecord::Base
  attr_accessible :expectation_id, :modified_by_id, :rank, :status,
    :title, :updated_at, :user_expectation_id, :user_id

  validates :expectation_id, presence: true
  validates :modified_by_id, presence: true
  validates :status, presence: true
  validates :title, presence: true
  validates :user_expectation_id, presence: true
  validates :user_id, presence: true

end
