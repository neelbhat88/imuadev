class OrgTest < ActiveRecord::Base
  attr_accessible :organization_id, :title, :score_type, :description

  belongs_to :organization

  has_many :user_tests, dependent: :destroy

  validates :organization_id, presence: true
  validates :title, :uniqueness => {:scope => [ :organization_id] },presence: true
  validates :score_type, presence: true

end
