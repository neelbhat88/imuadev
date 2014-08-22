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

    # User.includes([:user_milestones, :relationships]).where(:organization_id => @id).find_each do |user|
    #   viewUser = ViewUser.new(user)
    #   case viewUser.role
    #   when Constants.UserRole[:ORG_ADMIN]
    #     @orgAdmins << viewUser
    #   when Constants.UserRole[:MENTOR]
    #     @mentors << viewUser
    #   when Constants.UserRole[:STUDENT]
    #     @students << viewUser
    #   end
    # end

    User.includes([:user_milestones, :relationships]).where(:organization_id => @id).find_in_batches do |users|
      viewUsers = users.map{|u| ViewUser.new(u)}
      if @users.nil?
        @users = viewUsers
      else
        @users << viewUsers
      end

      # @orgAdmins = nil
      # @mentors = nil
      # @students = nil

      # if @orgAdmins.nil?
      #   @orgAdmins = viewUsers.select {|u| u.role == Constants.UserRole[:ORG_ADMIN]}
      #   @mentors = viewUsers.select {|u| u.role == Constants.UserRole[:MENTOR]}
      #   @students = viewUsers.select {|u| u.role == Constants.UserRole[:STUDENT]}
      # else
      #   @orgAdmins << viewUsers.select {|u| u.role == Constants.UserRole[:ORG_ADMIN]}
      #   @mentors << viewUsers.select {|u| u.role == Constants.UserRole[:MENTOR]}
      #   @students << viewUsers.select {|u| u.role == Constants.UserRole[:STUDENT]}
      # end
    end

  end

end
