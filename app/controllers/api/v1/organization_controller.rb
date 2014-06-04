class Api::V1::OrganizationController < ApplicationController

  before_filter :authenticate_user!
  skip_before_filter  :verify_authenticity_token

  respond_to :json

  # GET /organization
  def index
    result = OrganizationRepository.new.get_all_organizations()

    render status: 200,
      json: {
        success: result[:success],
        info: result[:info],
        organizations: result[:organizations]
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

    render status: 200,
      json: {
        success: true,
        info: "Roadmap",
        roadmap: roadmap
      }
  end

  # GET /organization/:id/modules
  def modules
    orgId = params[:orgId]

    enabled_modules = EnabledModules.new.get_modules(orgId)

    render status: 200,
      json: {
        success: true,
        info: "Modules for Organization",
        enabled_modules: enabled_modules
      }
  end

end

class EnabledModules
  def initialize
  end

  def get_modules(orgId)
    # Query DB to get enabled modules/submodules for an organization
    mod_array = [
        {
          :title => Constants.Modules[:ACADEMICS],
          :submodules => [Constants.SubModules[:ACADEMICS_GPA]]
        },
        {
          :title => Constants.Modules[:SERVICE],
          :submodules => [Constants.SubModules[:SERVICE_DEPTH_HOURS]]
        }
      ]

    mods = []
    mod_array.each do | m |
      mod = AppModule.new
      mod.title = m[:title]

      m[:submodules].each do | sm |
        mod.submodules << SubModuleFactory.new.get_submodule(sm)
      end

      mods << mod
    end

    return mods
  end

end

class AppModule
  attr_accessor :title, :submodules

  def initialize
    @submodules = []
  end

end

class SubModuleFactory
  def initialize
  end

  def get_submodule(sub_module)

    case sub_module
    when Constants.SubModules[:ACADEMICS_GPA]
      return AcademicsGpa.new
    when Constants.SubModules[:SERVICE_DEPTH_HOURS]
      return ServiceDepthHours.new
    end

  end
end