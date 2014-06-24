class RoadmapRepository
  def initialize
  end

  ######################################
  ############## ROADMAP ###############
  ######################################
  def get_roadmap_by_organization(orgId)
    roadmap = Roadmap.where(:organization_id => orgId)[0]

    return roadmap
  end

  def create_roadmap(roadmap)
    if Roadmap.where(:organization_id => roadmap[:organization_id]).length != 0
      return { :success => false, :info => "Roadmap for the organization already exists.", :roadmap => nil }
    elsif roadmap[:name] == "" || roadmap[:organization_id] == ""
      return { :success => false, :info => "Incorrect arguments received to create a roadmap.", :roadmap => nil }
    end

    newroadmap = Roadmap.new do | r |
      r.name = roadmap[:name]
      r.organization_id = roadmap[:organization_id]
    end

    if newroadmap.save
      return { :success => true, :info => "Roadmap created successfully.", :roadmap => newroadmap }
    end

    return { :success => false, :info => "Failed to create roadmap.", :roadmap => nil }

  end

  def create_roadmap_with_semesters(roadmap)
    result = create_roadmap(roadmap)

    return result if !result[:success]

    roadmap = result[:roadmap]

    # Create 8 semesters
    (1..8).each do | n |
      new_time_unit = roadmap.time_units.new do | tu |
        tu.name = "Semester " + n.to_s
        tu.organization_id = roadmap[:organization_id]
      end

      if !new_time_unit.save
        return { :success => false, :info => "Failed to create 8 semesters.", :roadmap => nil }
      end
    end

    return { :success => true, :info => "Roadmap with 8 semesters created successfully.", :roadmap => roadmap }

  end

  def update_roadmap(newroadmap)
    roadmap = Roadmap.find(newroadmap[:id])

    if roadmap.update_attributes(:name => newroadmap[:name])
      return { :status => :ok, :info => "Successfully updated Roadmap id:#{newroadmap[:id]}.", :roadmap => roadmap }
    else
      return { :status => :internal_server_error, :info => "Failed to update Roadmap id:#{newroadmap[:id]}.", :roadmap => roadmap }
    end
  end

  def delete_roadmap(roadmapId)
    if Roadmap.find(roadmapId).destroy()
      return { :success => true, :info => "Successfully deleted Roadmap id:#{roadmapId} and all of its time units and milestones." }
    else
      return { :success => false, :info => "Failed to delete Roadmap id:#{roadmapId}." }
    end
  end

  ######################################
  ############# TIME UNIT ##############
  ######################################

  def get_time_units(organization_id)
    return TimeUnit.where(:organization_id => organization_id).order(:id)
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

  ######################################
  ############# MILESTONE ##############
  ######################################

  def get_milestones_in_time_unit(time_unit_id)
    return Milestone.where(:time_unit_id => time_unit_id)
  end

  def create_milestone(milestone)
    default_points = 10

    newmilestone = nil

    if milestone[:time_unit_id].nil?
      newmilestone = Milestone.new

      # Only set is_default if this is not associated with a time_unit
      if milestone[:is_default].nil?
        return ReturnObject.new(:bad_request, "Must pass either a time_unit_id or is_default = true.", nil)
      end

      newmilestone.is_default = milestone[:is_default]
    else
      time_unit = TimeUnit.find(milestone[:time_unit_id])
      newmilestone = time_unit.milestones.new # This automatically sets the time_unit_id on the Milestone

      time_unit.milestones.each do | m |
        if m.module == milestone[:module] && m.submodule == milestone[:submodule] && m.value == milestone[:value]
          return ReturnObject.new(:conflict, "A milestone of the same type and value already exists in #{time_unit.name}.", nil)
        end
      end
    end

    newmilestone.module = milestone[:module]
    newmilestone.submodule = milestone[:submodule]
    newmilestone.importance = milestone[:importance]
    newmilestone.points = milestone[:points]
    newmilestone.title = milestone[:title]
    newmilestone.description = milestone[:description]
    newmilestone.value = milestone[:value]
    newmilestone.icon = milestone[:icon]

    if newmilestone.save
      return ReturnObject.new(:ok, "Successfully created Milestone id: #{newmilestone.id}.", newmilestone)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create milestone.", nil)
    end

  end

  def get_default_milestone(opts)
    mod = opts[:module]
    submod = opts[:submodule]

    milestones = Milestone.where(:is_default => true, :module => mod, :submodule => submod)

    if milestones.count > 1
      error = "ERROR: There is more than one default milestone for Module: #{mod}, SubModule: #{submod}"
      Rails.logger.error error

      # Send email out of process
      Background.process do
        UserMailer.log_error(error).deliver
      end
    end

    return milestones[0]
  end

  def update_milestone(ms)
    milestone = Milestone.find(ms[:id])

    if !milestone.time_unit_id.nil? # Default milestones don't have a time_unit
      milestone.time_unit.milestones.each do | m |
        if m.id != ms[:id] && (m.module == ms[:module] && m.submodule == ms[:submodule] && m.value == ms[:value])
          return ReturnObject.new(:conflict, "A milestone of the same type and value already exists in #{milestone.time_unit.name}.", nil)
        end
      end
    end

    if milestone.update_attributes(:title => ms[:title],
                                    :description=>ms[:description],
                                    :points => ms[:points],
                                    :value => ms[:value])
      return ReturnObject.new(:ok, "Successfully updated Milestone id: #{milestone.id}.", milestone)
    end

    return ReturnObject.new(:internal_server_error, "Failed to update Milestone id: #{milestone.id}.", milestone)
  end

  def delete_milestone(milestoneId)
    if Milestone.find(milestoneId).destroy()
      return ReturnObject.new(:ok, "Successfully deleted Milestone id: #{milestoneId}.", nil)
    else
      return ReturnObject.new(:internal_server_error, "Failed to delete Milestone id: #{milestoneId}.", nil)
    end
  end

end
