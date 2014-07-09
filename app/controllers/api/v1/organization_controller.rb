class Api::V1::OrganizationController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :load_services

  def load_services( organizationRepo=nil, roadmapRepo=nil, enabledModules=nil )
    @organizationRepository = organizationRepo ? organizationRepo : OrganizationRepository.new
    @roadmapRepository = roadmapRepo ? roadmapRepo : RoadmapRepository.new
    @enabledModules = enabledModules ? enabledModules : EnabledModules.new
  end

  # GET /organization
  def all_organizations
    if !current_user.super_admin?
      render status: :unauthorized,
        json: {}

      return
    end

    result = @organizationRepository.get_all_organizations()

    render status: result.status,
      json: {
        info: result.info,
        organizations: result.object
      }
  end

  # GET /organization/:id
  def get_organization
    orgId = params[:id].to_i

    if !current_user.super_admin? && current_user.organization_id != orgId
      render status: :forbidden, json: {}

      return
    end

    result = @organizationRepository.get_organization(orgId)

    viewOrg = ViewOrganization.new(result.object) unless result.object.nil?
    render status: result.status,
      json: {
        info: result.info,
        organization: viewOrg
      }
  end

  # POST /organization
  def create_organization
    name = params[:name]

    if name.nil?
      render stauts: 200,
          json: {
            success: false,
            info: "Must provide an organization name"
          }

      return
    end

    result = @organizationRepository.create_organization({:name => name})

    render stauts: 200,
      json: {
        success: result[:success],
        info: result[:info],
        organization: result[:organization]
      }
  end

  # PUT /organization/:id
  def update_organization
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
  def delete_organization
    orgId = params[:id]

    result = @organizationRepository.delete_organization(orgId)

    render stauts: 200,
      json: {
        success: result[:success],
        info: result[:info]
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
