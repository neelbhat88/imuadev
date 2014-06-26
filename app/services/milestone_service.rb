class MilestoneService
  def create_milestone(ms)
    milestone = MilestoneFactory.get_milestone(ms[:submodule])

    milestone.value = ms[:value]
    milestone.points = ms[:points]
    milestone.time_unit_id = ms[:time_unit_id]

    if !milestone.valid?
    end

    newmilestone = Milestone.new do | m |
      m.module = milestone.module
      m.submodule = milestone.submodule
      m.title = milestone.title
      m.description = milestone.description
      m.value = milestone.value
      m.icon = milestone.icon
      m.time_unit_id = milestone.time_unit_id
      m.importance = milestone.importance
      m.points = milestone.points
      m.icon = milestone.icon
    end

    if newmilestone.save
      return ReturnObject.new(:ok, "Successfully created Milestone id: #{newmilestone.id}.", newmilestone)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create milestone.", nil)
    end
  end

  # REwork this, don't need default milestones in the DB
  def get_default_milestone(submodule)
    milestones = Milestone.where(:is_default => true, :submodule => submodule)

    if milestones.empty? # If not stored in DB return code default
      milestone = MilestoneFactory.get_milestone(submodule)

      return milestone.default_milestone
    elsif milestones.count > 1
      error = "ERROR: There is more than one default milestone for SubModule: #{submod}"
      Rails.logger.error error

      # Send email out of process
      Background.process do
        UserMailer.log_error(error).deliver
      end
    end

    return milestones[0]
  end

end
