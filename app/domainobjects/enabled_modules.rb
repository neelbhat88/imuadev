class EnabledModules
  def initialize
  end

  def populate_modules_array(orgId)
    # TODO: Query DB to get enabled modules/submodules for an organization
    mod_array = [
      {
        :title => Constants.Modules[:ACADEMICS],
        :submodules => [Constants.SubModules[:ACADEMICS_GPA],
                        Constants.SubModules[:YES_NO]]
      },
      {
        :title => Constants.Modules[:SERVICE],
        :submodules => [Constants.SubModules[:SERVICE_HOURS],
                        Constants.SubModules[:SERVICE_DEPTH_HOURS],
                        Constants.SubModules[:YES_NO]]
      },
      {
        :title => Constants.Modules[:EXTRACURRICULAR],
        :submodules => [Constants.SubModules[:EXTRACURRICULAR_ACTIVITIES],
                        Constants.SubModules[:EXTRACURRICULAR_DEPTH_ACTIVITIES],
                        Constants.SubModules[:EXTRACURRICULAR_LEADERSHIP_ACTIVITIES],
                        Constants.SubModules[:YES_NO]]
      },
      {
        :title => Constants.Modules[:COLLEGE_PREP],
        :submodules => [Constants.SubModules[:YES_NO]]
      },
      {
        :title => Constants.Modules[:TESTING],
        :submodules => [Constants.SubModules[:TESTING_TAKE],
                        Constants.SubModules[:YES_NO]]
      }
    ]
    return mod_array
  end


  def get_modules(orgId)
    mod_array = populate_modules_array(orgId)

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

  def get_enabled_module_titles(orgId)
    mod_array = populate_modules_array(orgId)

    mods = []
    mod_array.each do | m |
      mod = AppModule.new
      mod.title = m[:title]
      mods << DomainModule.new(mod)
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

class DomainModule

  def initialize(m, options = {})
    @title = m.title

    @submodules = options[:submodules] unless options[:submodules].nil?
  end

end
