class RoadmapRepository
  def initialize
  end

  def get_roadmap_by_organization(orgId)
    roadmap = Roadmap.where(:organization_id => orgId)[0]

    return ViewRoadmap.new(roadmap)
  end

  def create_roadmap(roadmap)
    if Roadmap.where(:organization_id => roadmap[:organization_id]).length != 0
      return { :success => false, :info => "Roadmap for the organization already exists.", :roadmap => nil }
    end

    newroadmap = Roadmap.new do | r |
      r.name = roadmap[:name]
      r.description = roadmap[:description],
      r.organization_id = roadmap[:organization_id]
    end

    if newroadmap.save
      return { :success => true, :info => "Roadmap created successfully.", :roadmap => newroadmap }
    end

    return { :success => false, :info => "Failed to create roadmap.", :roadmap => nil }

  end

  def create_time_unit(time_unit)
    roadmap = Roadmap.find(time_unit[:roadmap_id])

    new_time_unit = roadmap.time_units.new do | tu |
      tu.name = time_unit[:name]
      tu.organization_id = time_unit[:organization_id]
    end

    if new_time_unit.save
      return { :success => true, :info => "Time unit created successfully.", :time_unit => new_time_unit }
    else
      return { :success => false, :info => "Failed to create time unit.", :time_unit => nil }
    end
  end

  def update_time_unit(time_unit)
    tu = TimeUnit.find(time_unit[:id])

    if tu.update_attributes(:name => time_unit[:name])
      return { :success => true, :info => "Successfully updated Time Unit id:#{time_unit[:id]}.", :time_unit => tu }
    else
      return { :success => false, :info => "Failed to update Time Unit id:#{time_unit[:id]}.", :time_unit => tu }
    end
  end

  def delete_time_unit(time_unit_id)
    if TimeUnit.find(time_unit_id).destroy()
      return { :success => true, :info => "Successfully deleted Time Unit id:#{time_unit_id} and all of its milestones." }
    else
      return { :success => false, :info => "Failed to delete Time Unit id:#{time_unit_id}." }
    end
  end

  def create_milestone(milestone)
    default_points = 10

    newmilestone = nil

    if milestone[:time_unit_id].nil?
      newmilestone = Milestone.new

      # Only set is_default if this is not associated with a time_unit
      newmilestone.is_default = milestone[:is_default] if !milestone[:is_default].nil?
    else
      time_unit = TimeUnit.find(milestone[:time_unit_id])
      newmilestone = time_unit.milestones.new # This automatically sets the time_unit_id on the Milestone

    end

    newmilestone.module = milestone[:module]
    newmilestone.submodule = milestone[:submodule]
    newmilestone.importance = milestone[:importance]
    newmilestone.points = default_points
    newmilestone.title = milestone[:title]
    newmilestone.description = milestone[:description]

    milestone[:milestone_levels].each do | l |
      newmilestone.milestone_levels.new do | ml |
        ml.value = l[:value]
      end
    end

    if newmilestone.save
      return { :success => true, :info => "Milestone created successfully.", :milestone => newmilestone }
    else
      return { :success => false, :info => "Failed to create milestone.", :milestone => nil }
    end

  end

  def get_default_milestone(opts)
    mod = opts[:module]
    submod = opts[:submodule]

    milestones = Milestone.where(:is_default => true, :module => mod, :submodule => submod)

    if milestones.count > 1
      error = "ERROR: There is more than one default milestone for Module: #{mod}, SubModule: #{submod}"
      Rails.logger.error error
      UserMailer.log_error(error).deliver
    end

    return milestones[0]
  end

  def update_milestone(ms)
    milestone = Milestone.find(ms[:id])

    if milestone.update_attributes(:title => ms[:title], :description=>ms[:description],
                                    :importance => ms[:importance])

      ms[:milestone_levels].each do |ml|
        level = milestone.milestone_levels.find(ml[:id])

        if !level.update_attributes(:title => ml[:title], :value => ml[:value])
          return { :success => false, :info=>"Milestone level id: #{level.id} failed to update", :milestone=>milestone }
        end
      end

      return { :success => true, :info=>"Milestone updated successfully", :milestone=>milestone }

    end

    return { :success => false, :info=>"Milestone failed to update", :milestone=>milestone }
  end

end