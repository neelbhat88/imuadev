class Api::V1::OrganizationController < ApplicationController

  before_filter :authenticate_user!
  skip_before_filter  :verify_authenticity_token

  respond_to :json

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
        { :title => "Academics", :submodules => ["GPA"] },
        #{ :title => "Service", :submodules => ["Hours"] }
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
      return GpaSubModule.new
    end

  end
end