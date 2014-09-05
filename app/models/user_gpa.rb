class UserGpa < ActiveRecord::Base
  attr_accessible :core_unweighted, :core_weighted, :regular_unweighted,
                  :regular_weighted, :time_unit_id, :user_id

  belongs_to :user

  validates :time_unit_id, presence: true
  validates :user_id, presence: true
end
