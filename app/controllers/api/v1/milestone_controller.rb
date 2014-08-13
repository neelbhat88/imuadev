class Api::V1::MilestoneController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :load_services

  def load_services ( milestoneService = nil, organizationRepo = nil, userRepo = nil )
    @milestoneService = milestoneService ? milestoneService : MilestoneService.new
    @organizationRepository = organizationRepo ? organizationRepo : OrganizationRepository.new
    @userRepository = userRepo ? userRepo : UserRepository.new
  end

  # GET /organization/:id/milestones?time_unit_id=#
  def get_org_milestones
    orgId      = params[:id]
    timeUnitId = params[:time_unit_id]

    org = @organizationRepository.get_organization(orgId)
    if !can?(current_user, :read_org_milestones, org)
      render status: :forbidden,
        json: {}
      return
    end

    result = @milestoneService.get_org_milestones(orgId, timeUnitId)

    render status: result.status,
      json: {
        info: result.info,
        milestones: result.object
      }
  end

  # GET /user/:id/user_milestones?time_unit_id=#
  def get_user_milestones
    userId     = params[:id]
    timeUnitId = params[:time_unit_id]

    user = @userRepository.get_user(userId)
    if !can?(current_user, :read_user_milestones, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @milestoneService.get_user_milestones(userId, timeUnitId)

    render status: result.status,
      json: {
        info: result.info,
        milestones: result.object
      }
  end

  # GET /user/:id/milestones?time_unit_id=#
  def get_user_and_org_milestones
    userId     = params[:id]
    timeUnitId = params[:time_unit_id]

    user = @userRepository.get_user(userId)
    if !can?(current_user, :read_user_milestones, user)
      render status: :forbidden,
        json: {}
      return
    end

    orgId = user.organization_id
    org = @organizationRepository.get_organization(orgId)
    if !can?(current_user, :read_org_milestones, org)
      render status: :forbidden,
        json: {}
      return
    end

    result = @milestoneService.get_user_and_org_milestones(userId, orgId, timeUnitId)

    render status: result.status,
      json: {
        info: result.info,
        milestones: result.object
      }
  end

  # POST /milestone
  def create_milestone
    tuId = params[:milestone][:time_unit_id]
    mod = params[:milestone][:module]
    submod = params[:milestone][:submodule]
    importance = params[:milestone][:importance]
    points = params[:milestone][:points]
    title = params[:milestone][:title]
    desc = params[:milestone][:description]
    is_default = params[:milestone][:is_default]
    value = params[:milestone][:value]
    icon = params[:milestone][:icon]

    milestone = { :module => mod, :submodule=> submod, :importance => importance, :points => points,
                  :title => title, :description => desc, :value => value, :time_unit_id => tuId,
                  :is_default => is_default, :icon => icon, :organization_id => current_user.organization_id }

    result = MilestoneService.new.create_milestone(milestone)

    viewMilestone = ViewMilestone.new(result.object) unless result.object.nil?
    render status: result.status,
      json: {
        info: result.info,
        milestone: viewMilestone
      }
  end

  # PUT /milestone/:id
  def update_milestone
    milestoneId = params[:id]
    milestone = params[:milestone]

    if milestone[:id].nil?
      milestone[:id] = milestoneId
    end

    result = MilestoneService.new.update_milestone(milestone)

    viewMilestone = ViewMilestone.new(result.object) unless result.object.nil?
    render status: result.status,
      json: {
        info: result.info,
        milestone: viewMilestone
      }
  end

  # DELETE /milestone/:id
  def delete_milestone
    milestoneId = params[:id]

    result = MilestoneService.new.delete_milestone(milestoneId)

    render status: result.status,
      json: {
        info: result.info
      }
  end

end
