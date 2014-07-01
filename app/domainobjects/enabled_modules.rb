class EnabledModules
  def initialize
  end

  def get_modules(orgId)
    # TODO: Query DB to get enabled modules/submodules for an organization
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
        mod.submodules << MilestoneFactory.get_milestone(sm)
      end

      mods << mod
    end

    return ReturnObject.new(:ok, "Submodules for orgId: #{orgId}", mods)
  end

end

class AppModule
  attr_accessor :title, :submodules

  def initialize
    @submodules = []
  end

end

# class SubModuleFactory
#   def initialize
#   end
#
#   def get_submodule(sub_module)
#
#     case sub_module
#     when Constants.SubModules[:ACADEMICS_GPA]
# #      return AcademicsGpa.new
#       return GpaMilestone.new
#     when Constants.SubModules[:SERVICE_DEPTH_HOURS]
# #      return ServiceDepthHours.new
#       return DepthHoursMilestone.new
#     end
#
#   end
# end
