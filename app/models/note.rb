class Note < ActiveRecord::Base
  attr_accessible :created_by, :date, :message, :time_spent, :note_type, :user_id, :is_private

  belongs_to :user_id, dependent: :destroy

  validates :note_type, presence: true
  validates :user_id, presence: true
  validates :created_by, presence: true
  validates :message, presence: true

end
