class ProgressService

  def get_all_progress(userId, time_unit_id)
    user = UserRepository.new.get_user(userId)
    enabled_modules = EnabledModules.new.get_modules(user.organization_id).object

    modules_progress = []
    enabled_modules.each do | m |
      points = get_module_and_user_points(userId, time_unit_id, m.title)

      mod = ModuleProgress.new(m.title, points[:user], points[:total])

      modules_progress << mod
    end

    return ReturnObject.new(:ok, "All modules progress", modules_progress)
  end

  def check_progress(userId, time_unit_id, module_title)
    user = UserRepository.new.get_user(userId)

    # Get all Milestones for given category and time_unit
    # Loop through and call has_earned? method
    # Add to UserMilestone if earned, Delete if not earned and user had previously earned the milestone
    org_milestones = Milestone.where(:module => module_title, :time_unit_id => time_unit_id)
    users_milestones = UserMilestone.where(:user_id => userId, :module => module_title, :time_unit_id => time_unit_id)

    # ToDo: We can probably filter out all the Yes/No milestones here and skip calling has_earned? on all Yes/No milestones
    # to save a DB call. Yes/No milestone are simple and we know they earned or lost based on checking/unchecking a checkbox so don't need to check again
    # here when saving other Academics data
    # For now this is fine, but if DB starts taking a hit we can save some calls here
    milestones = MilestoneFactory.get_milestone_objects(org_milestones)

    milestones.each do | m |
      earned = m.has_earned?(user, time_unit_id)
      user_has_milestone = users_milestones.select{|um| um.milestone_id == m.id}.length > 0

      Rails.logger.debug "*****Milestone id: #{m.id}, value: #{m.value} earned? #{earned}"
      if earned and !user_has_milestone
        MilestoneService.new.add_user_milestone(userId, time_unit_id, m.id)
        Rails.logger.debug "*****Milestone added to UserMilestone table"
      elsif !earned and user_has_milestone
        MilestoneService.new.delete_user_milestone(userId, time_unit_id, m.id)
        Rails.logger.debug "*****Milestone deleted from UserMilestone table"
      end
    end

    # Get total and user points
    points = get_module_and_user_points(userId, time_unit_id, module_title)
    mod = ModuleProgress.new(module_title, points[:user], points[:total])

    return ReturnObject.new(:ok, "#{module_title} progress", mod)
  end

  private

  def get_module_and_user_points(userId, time_unit_id, module_title)
    org_milestones = Milestone.where(:module => module_title, :time_unit_id => time_unit_id)
    total_points = 0
    org_milestones.each do | om |
      total_points += om.points
    end

    users_milestones = UserMilestone.where(:user_id => userId, :module => module_title, :time_unit_id => time_unit_id)
    user_points = 0
    users_milestones.each do | um |
      user_points += um.milestone.points
    end

    return {:total => total_points, :user => user_points}
  end
end

class ModuleProgress
  attr_accessor :module_title, :points

  def initialize(title, user_points, total_points)
    @module_title = title
    @points = {:user => user_points, :total => total_points}
  end

end
