class AccessToken < ActiveRecord::Base
  attr_accessible :token_value, :user_id

  belongs_to :user

  validates :token_value, presence: true
  validates :user_id, presence: true
end
