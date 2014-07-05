class Api::V1::OrganizationController < ApplicationController

  before_filter :authenticate_user!

  respond_to :json

  # GET /organization
  def all_organizations
    result = OrganizationRepository.new.get_all_organizations()

    render status: result.status,
      json: {
        info: result.info,
        organizations: result.object
      }
  end

  # GET /organization/:id
  def get_organization
    orgId = params[:id]

    result = OrganizationRepository.new.get_organization(orgId)

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

    result = OrganizationRepository.new.create_organization({:name => name})

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

    result = OrganizationRepository.new.update_organization({:id => orgId, :name => name})

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

    result = OrganizationRepository.new.delete_organization(orgId)

    render stauts: 200,
      json: {
        success: result[:success],
        info: result[:info]
      }
  end

  # GET /organization/:id/roadmap
  def roadmap
    orgId = params[:id].to_i

    roadmap = RoadmapRepository.new.get_roadmap_by_organization(orgId)

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

    result = EnabledModules.new.get_modules(orgId)

    render status: result.status,
      json: {
        info: result.info,
        enabled_modules: result.object
      }
  end

  # GET /organization/:id/time_units
  def time_units
    orgId = params[:id].to_i

    org_time_units = RoadmapRepository.new.get_time_units(orgId)

    render status: 200,
      json: {
        success: true,
        info: "Time Units for Organization",
        org_time_units: org_time_units
      }
  end

end
