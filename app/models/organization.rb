class Organization < ActiveRecord::Base
  attr_accessible :name

  has_many :users
  has_one :roadmap
end

class ViewOrganization
  attr_accessor :id, :name, :orgAdmins, :students, :mentors

  def initialize(org)
    @id = org.id
    @name = org.name

    users = org.users.map{|u| ViewUser.new(u)}
    @orgAdmins = users.select {|u| u.role == Constants.UserRole[:ORG_ADMIN]}
    @mentors = users.select {|u| u.role == Constants.UserRole[:MENTOR]}
    @students = users.select {|u| u.role == Constants.UserRole[:STUDENT]}
  end
end
