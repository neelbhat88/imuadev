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

  def initialize(org)
    @id = org.id
    @name = org.name
    @milestones = nil
    @users = nil

    Milestone.where(:organization_id => @id).find_in_batches do |milestones|
      viewMilestones = milestones.map{|m| ViewMilestone.new(m)}
      if @milestones.nil?
        @milestones = milestones
      else
        @milestones << milestones
      end
    end

    User.includes([:user_milestones, :relationships, :user_expectations,
                   :user_classes, :user_extracurricular_activity_details,
                   :user_service_hours, :user_tests])
                   .where(:organization_id => @id).find_in_batches do |users|
      viewUsers = users.map{|u| ViewUser.new(u)}
      if @users.nil?
        @users = viewUsers
      else
        @users << viewUsers
      end
    end

  end

end
