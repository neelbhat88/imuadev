class ProgressService

  def get_all_progress(userId, time_unit_id)
    user = UserRepository.new.get_user(userId)
    enabled_modules = EnabledModules.new.get_modules(user.organization_id)

    modules_progress = []
    enabled_modules.each do | m |
      org_milestones = Milestone.where(:module => m.title, :time_unit_id => time_unit_id)
      total_points = 0
      org_milestones.each do | om |
        total_points += om.points
      end
      
      #users_milestones = EarnedMilestone.where(:user_id => userId, :module => m.title, :time_unit_id => time_unit_id)
      user_points = 0
      # users_milestones.each do | um |
      #   user_points += um.milestone.points
      # end

      mod = ModuleProgress.new(m.title)
      mod.set_points({:user => user_points, :total => total_points})

      modules_progress << mod
    end

    return ReturnObject.new(:ok, "All modules progress", modules_progress)
  end

  def get_user_classes(userId, time_unit_id)
    return UserClass.where(:user_id => userId, :time_unit_id => time_unit_id).order(:id)
  end

  def save_user_class(userId, user_class)
    new_class = UserClass.new do | u |
      u.user_id = userId
      u.name = user_class[:name]
      u.grade = user_class[:grade]
      u.gpa = get_gpa(user_class[:grade])
      u.time_unit_id = user_class[:time_unit_id]
    end

    if new_class.save
      return new_class
    else
      return nil
    end
  end

  def update_user_class(user_class)
    db_class = UserClass.find(user_class[:id])

    if db_class.update_attributes(:name => user_class[:name], :grade => user_class[:grade], :gpa => get_gpa(user_class[:grade]))
      return db_class
    else
      return nil
    end
  end

  def delete_user_class(classId)
    if UserClass.find(classId).destroy()
      return true
    else
      return false
    end
  end

  private

  def get_gpa(grade)
    gpaHash = Hash.new()
    gpaHash = {
      'A' =>  4.0,  'A-' => 3.67,
      'B+' => 3.33, 'B' =>  3.00, 'B-' => 2.67,
      'C+' => 2.33, 'C' =>  2.00, 'C-' => 1.67,
      'D+' => 1.33, 'D' =>  1.00, 'D-' => 0.67,
      'F' =>  0.0
    }

    gpa = gpaHash[grade]

    return gpa
  end

  def get_total_points(milestones)
    points = 0
    milestones.each do | m |
      points += m.points
    end

    return points
  end
end

class ModuleProgress
  attr_accessor :module_title, :points

  def initialize(title)
    @module_title = title
    @points = {:user => 0, :total => 0}
  end

  def set_points(opts)
    @points = {:user => opts[:user], :total => opts[:total]}
  end

end
