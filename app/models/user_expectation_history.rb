class UserExpectationHistory < ActiveRecord::Base
  attr_accessible :expectation_id, :modified_by_id, :rank, :status,
    :title, :user_expectation_id, :user_id, :modified_by_name, :comment,
    :created_on

  validates :expectation_id, presence: true
  validates :status, presence: true
  validates :title, presence: true
  validates :user_expectation_id, presence: true
  validates :user_id, presence: true
  validates :created_on, presence: true

end
