class ParentGuardianContact < ActiveRecord::Base
  attr_accessible :user_id, :name, :relationship, :email, :phone

  belongs_to :user

  validates :user_id, presence: true
  validates :name, presence: true
  validates :relationship, presence: true
  validates :phone, presence: true
end
