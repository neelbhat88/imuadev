class Expectation < ActiveRecord::Base
  attr_accessible :organization_id, :title, :description, :rank

  belongs_to :organization

  has_many :user_expectations, dependent: :destroy
  # NEVER EVER USE THIS RELATION -- This is here purely for the dependent destroy
  has_many :user_expectation_histories, dependent: :destroy

  validates :organization_id, presence: true
  validates :title, :uniqueness => {:scope => [ :organization_id] },presence: true
  validates :description, presence: true
  validates :rank, presence: true
end

class ViewExpectation
  attr_accessor :id, :title, :description, :rank

  def initialize(expectation)
    @id = expectation.id
    @title = expectation.title
    @description = expectation.description
    @rank = expectation.rank
  end

end
