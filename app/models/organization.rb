class Organization < ActiveRecord::Base
  attr_accessible :name

  has_many :users, dependent: :destroy
  has_many :expectations, dependent: :destroy
  has_one :roadmap, dependent: :destroy
end

class ViewOrganization
  attr_accessor :id, :name, :orgAdmins, :students, :mentors, :expectations

  def initialize(org)
    @id = org.id
    @name = org.name

    users = org.users.map{|u| ViewUser.new(u)}
    @orgAdmins = users.select {|u| u.role == Constants.UserRole[:ORG_ADMIN]}
    @mentors = users.select {|u| u.role == Constants.UserRole[:MENTOR]}
    @students = users.select {|u| u.role == Constants.UserRole[:STUDENT]}

    @expectations = []
    org.expectations.each do | e |
      @expectations << ViewExpectation.new(e)
    end

  end
end
