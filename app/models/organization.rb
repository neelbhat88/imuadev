class Organization < ActiveRecord::Base
  attr_accessible :name

  has_many :users
end

class ViewOrganization
  attr_accessor :id, :name, :orgAdmins

  def initialize(org)
    @id = org.id
    @name = org.name

    users = org.users.map{|u| ViewUser.new(u)}
    @orgAdmins = users.select {|u| u.role == Constants.UserRole[:ORG_ADMIN]}
  end
end
