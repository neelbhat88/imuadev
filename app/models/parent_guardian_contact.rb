class ParentGuardianContact < ActiveRecord::Base
  attr_accessible :user_id, :name, :relationship, :email, :phone

  belongs_to :user

  validates :user_id, presence: true
  validates :name, presence: true
  validates :relationship, presence: true
  validates :phone, presence: true
end

class ViewParentGuardianContact
  attr_accessor :id, :user_id, :name, :relationship, :email, :phone

  def initialize(contact)
    @id           = contact.id
    @user_id      = contact.user_id
    @name         = contact.name
    @relationship = contact.relationship
    @email        = contact.email
    @phone        = contact.phone
  end

end
