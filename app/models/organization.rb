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
    @time_units = TimeUnit.where(:organization_id => @id)
    @enabled_modules = EnabledModules.new.get_enabled_module_titles(@id)
    # @expectations = Expectation.where(:organization_id => @id).map{|e| ViewExpectation.new(e)}
    # @org_tests = OrgTests.where(:organization_id => @id).map{|e| ViewOrgTest.new(e)}

    users = nil
    if !options[:user_ids].nil?
      users = User.includes([:user_milestones, :relationships, :user_expectations,
                             :user_classes, :user_extracurricular_activity_details,
                             :user_service_hours, :user_tests, :user_gpas])
                             .where(:id => options[:user_ids])
    else
      users = User.includes([:user_milestones, :relationships, :user_expectations,
                             :user_classes, :user_extracurricular_activity_details,
                             :user_service_hours, :user_tests, :user_gpas])
                             .where(:organization_id => @id)
    end
    @users = users.map{|u| ViewUser.new(u)} unless users.nil?

  end

end

class DomainOrganization

  def initialize(org, options = {})

    unless org.nil?
      @id = org.id
      @name = org.name
    end

    @time_units = options[:time_units] unless options[:time_units].nil?
    @enabled_modules = options[:enabled_modules] unless options[:enabled_modules].nil?
    @milestones = options[:milestones] unless options[:milestones].nil?
    @expectations = options[:expectations] unless options[:expectations].nil?
    @org_tests = options[:org_tests] unless options[:org_tests].nil?
    @users = options[:users] unless options[:users].nil?
  end

end

class ViewOrganization2

  def initialize(options = {})

    org = options[:organization]
    unless org.nil?
      @id = org.id unless org.id.nil?
      @name = org.name unless org.name.nil?
    end

    @time_units = options[:time_units] unless options[:time_units].nil?
    @enabled_modules = options[:enabled_modules] unless options[:enabled_modules].nil?
    @milestones = options[:milestones] unless options[:milestones].nil?
    @expectations = options[:expectations] unless options[:expectations].nil?
    @org_tests = options[:org_tests] unless options[:org_tests].nil?
    @users = options[:users] unless options[:users].nil?
  end

end
