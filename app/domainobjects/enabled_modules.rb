class EnabledModules
  def initialize
  end

  def get_modules(orgId)
    # TODO: Query DB to get enabled modules/submodules for an organization
    mod_array = [
        {
          :title => Constants.Modules[:ACADEMICS],
          :submodules => [Constants.SubModules[:ACADEMICS_GPA],
                          Constants.SubModules[:YES_NO]]
        },
        {
          :title => Constants.Modules[:SERVICE],
          :submodules => [Constants.SubModules[:SERVICE_DEPTH_HOURS],
                          Constants.SubModules[:YES_NO]]
        },
        {
          :title => Constants.Modules[:EXTRACURRICULAR],
          :submodules => [Constants.SubModules[:YES_NO]]
        },
        {
          :title => Constants.Modules[:PDU],
          :submodules => [Constants.SubModules[:YES_NO]]
        },
        {
          :title => Constants.Modules[:TEST],
          :submodules => [Constants.SubModules[:YES_NO]]
        }
      ]

    mods = []
    mod_array.each do | m |
      mod = AppModule.new
      mod.title = m[:title]

      m[:submodules].each do | sm |
        mod.submodules << MilestoneFactory.get_milestone(mod.title, sm)
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
