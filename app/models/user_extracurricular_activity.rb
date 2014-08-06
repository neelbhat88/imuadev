class UserExtracurricularActivity < ActiveRecord::Base
  attr_accessible :name, :user_id, :description

  belongs_to :user

  validates :name, presence: true
  validates :user_id, presence: true
end
