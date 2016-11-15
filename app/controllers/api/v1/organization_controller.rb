class Api::V1::OrganizationController < ApplicationController
  respond_to :json

  before_filter :load_services

  def load_services( organizationRepo=nil, roadmapRepo=nil, enabledModules=nil, progressService = nil )
    @organizationRepository = organizationRepo ? organizationRepo : OrganizationRepository.new
    @roadmapRepository = roadmapRepo ? roadmapRepo : RoadmapRepository.new
    @enabledModules = enabledModules ? enabledModules : EnabledModules.new
    @progressService = progressService ? progressService : ProgressService.new
  end

  # GET /organization
  def index
    if !current_user.super_admin?
      render status: :forbidden, json: {}
      return
    end

    result = @organizationRepository.get_all_organizations()

    render status: result.status,
      json: {
        info: result.info,
        organizations: result.object
      }
  end

  # POST /organization
  def create
    if !current_user.super_admin?
      render status: :forbidden,
        json: {}
      return
    end

    name = params[:name]

    if name.nil? || name == ""
      render status: :forbidden,
          json: {
            success: false,
            info: "Must provide an organization name"
          }

      return
    end

    result = @organizationRepository.create_organization({:name => name})

    render status: result[:status],
      json: {
        success: result[:success],
        info: result[:info],
        organization: result[:organization]
      }
  end

  # PUT /organization/:id
  def update
    orgId = params[:id]
    name = params[:name]

    result = @organizationRepository.update_organization({:id => orgId, :name => name})

    render status: 200,
      json: {
        success: result[:success],
        info: result[:info],
        organization: result[:organization]
      }
  end

  # DELETE /organization/:id
  def destroy
    orgId = params[:id]

    result = @organizationRepository.delete_organization(orgId)

    render status: 200,
      json: {
        success: result[:success],
        info: result[:info]
      }
  end

  # GET /organization/:id/info_with_roadmap
  def organization_with_roadmap
    orgId = params[:id].to_i

    if !same_organization?(orgId)
      render status: :forbidden, json: {}
      return
    end

    org = @organizationRepository.get_organization(orgId)
    admins = org.users.where(:role => Constants.UserRole[:ORG_ADMIN])

    roadmap = @roadmapRepository.get_roadmap_by_organization(orgId)
    viewRoadmap = ViewRoadmap.new(roadmap) unless roadmap.nil?

    render status: :ok,
      json: {
        info: "Organization with Roadmap",
        organization: {id: org.id, name: org.name, orgAdmins: admins.map {|u| ViewUser.new(u)} },
        roadmap: viewRoadmap
      }
  end

  def organization_with_users
    url_params = params.except(*[:id, :controller, :action]).symbolize_keys
    url_params[:organization_id] = params[:id]

    if !can?(current_user, :get_organization_progress, Organization.where(id: params[:id]).first)
      render status: :forbidden, json: {}
      return
    end

    result = @progressService.get_organization_progress(url_params)

    render status: result.status,
      json: Oj.dump({
        info: result.info,
        organization: result.object
      }, mode: :compat)
  end

  # GET /organization/:id/info_with_users
  def organization_with_users_old
    orgId = params[:id].to_i

    # TODO Change authorization to check this particular function
    if !same_organization?(orgId)
      render status: :forbidden, json: {}
      return
    end

    org = @organizationRepository.get_organization(orgId)
    # TODO Check authorization for this function
    # if !can?(current_user, :read_organization_with_users, org)
    #   render status: :forbidden, json: {}
    #   return
    # end

    viewOrg = ViewOrganizationWithUsers.new(org) unless org.nil?

    render status: :ok,
      json: {
        info: "Organization with Users",
        organization: viewOrg
      }
  end

  # GET /organization/:id/roadmap
  def roadmap
    orgId = params[:id].to_i

    roadmap = @roadmapRepository.get_roadmap_by_organization(orgId)

    viewRoadmap = ViewRoadmap.new(roadmap) unless roadmap.nil?
    render status: 200,
      json: {
        success: true,
        info: "Roadmap",
        roadmap: viewRoadmap
      }
  end

  # GET /organization/:id/modules
  def modules
    orgId = params[:id]

    result = @enabledModules.get_modules(orgId)

    render status: result.status,
      json: {
        info: result.info,
        enabled_modules: result.object
      }
  end

  # GET /organization/:id/time_units
  def time_units
    orgId = params[:id].to_i

    org_time_units = @roadmapRepository.get_time_units(orgId)

    render status: 200,
      json: {
        success: true,
        info: "Time Units for Organization",
        org_time_units: org_time_units
      }
  end

end
