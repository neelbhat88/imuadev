class Organization < ActiveRecord::Base
  attr_accessible :name

  has_many :users, dependent: :destroy
  has_many :expectations, dependent: :destroy
  has_one :roadmap, dependent: :destroy
  has_many :time_units, dependent: :destroy
  has_many :milestones, dependent: :destroy
  has_many :org_tests, dependent: :destroy
end

class ViewOrganizationWithUsers
  attr_accessor :id, :name, :orgAdmins, :students, :mentors

  def initialize(org, options = {})
    @id = org.id
    @name = org.name

    @milestones = Milestone.where(:organization_id => @id).map{|m| ViewMilestone.new(m)}
    # @expectations = Expectation.where(:organization_id => @id).map{|e| ViewExpectation.new(e)}
    # @org_tests = OrgTests.where(:organization_id => @id).map{|e| ViewOrgTest.new(e)}

    users = nil
    if !options[:user_ids].nil?
      users = User.includes([:user_milestones, :relationships, :user_expectations,
                             :user_classes, :user_extracurricular_activity_details,
                             :user_service_hours, :user_tests])
                             .where(:id => options[:user_ids])
    else
      users = User.includes([:user_milestones, :relationships, :user_expectations,
                             :user_classes, :user_extracurricular_activity_details,
                             :user_service_hours, :user_tests])
                             .where(:organization_id => @id)
    end
    @users = users.map{|u| ViewUser.new(u)} unless users.nil?

  end

end
