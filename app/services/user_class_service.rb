class UserClassService

  def get_user_classes(userId, time_unit_id)
    if time_unit_id == 0
      return UserClass.where(:user_id => userId).order(:id)
    end

    return UserClass.where(:user_id => userId, :time_unit_id => time_unit_id).order(:id)
  end

  def get_user_classes_2(filters = {})
    userClasses = nil

    if !defined?(filters[:module]) || filters[:module] == Constants.Modules[:ACADEMICS]
      applicable_filters = FilterFactory.new.conditions(UserClass.column_names.map(&:to_sym), filters)
      userClasses = UserClass.find(:all, :conditions => applicable_filters)
    end

    return userClasses.map{|uc| DomainUserClass.new(uc)} unless userClasses.nil?
  end

  def user_gpa(userId, time_unit_id)
    classes = get_user_classes(userId, time_unit_id)

    totalGpa = 0.0
    totalClassCredits = 0.0
    classes.each do | c |
      totalGpa += (c.gpa * c.credit_hours)
      totalClassCredits += c.credit_hours
    end

    return (totalGpa / totalClassCredits).round(2)
  end

  def save_user_class(current_user, userId, user_class)
    new_class = UserClass.new do | u |
      u.user_id = userId
      u.name = user_class[:name]
      u.grade = get_grade(user_class[:grade_value])
      u.grade_value = user_class[:grade_value]
      u.gpa = get_gpa(u.grade)
      u.time_unit_id = user_class[:time_unit_id]
      u.period = user_class[:period]
      u.room = user_class[:room]
      u.credit_hours = user_class[:credit_hours] ? user_class[:credit_hours] : 1
      u.level = user_class[:level] ? user_class[:level] : Constants.ClassLevels[:REGULAR]
      u.subject = user_class[:subject]
      u.modified_by_id = current_user.id
      u.modified_by_name = current_user.full_name
    end

    if new_class.save
      UserClassHistoryService.new.log_history(current_user, new_class)
      UserGpaService.new.calculate_gpa(userId, user_class[:time_unit_id])

      return ReturnObject.new(:ok, "User class created successfully", new_class)
    else
      return ReturnObject.new(:bad_request, "Failed to create a user class", nil)
    end
  end

  def update_user_class(current_user, class_id, user_class)
    db_class = UserClass.find(class_id)

    if db_class.update_attributes(:name => user_class[:name],
                                  :grade => get_grade(user_class[:grade_value]),
                                  :grade_value => user_class[:grade_value],
                                  :gpa => get_gpa(get_grade(user_class[:grade_value])),
                                  :period => user_class[:period],
                                  :room => user_class[:room],
                                  :credit_hours => user_class[:credit_hours],
                                  :level => user_class[:level],
                                  :subject => user_class[:subject],
                                  :modified_by_id => current_user.id,
                                  :modified_by_name => current_user.full_name
                                  )

      UserClassHistoryService.new.log_history(current_user, db_class)
      UserGpaService.new.calculate_gpa(db_class.user_id, db_class.time_unit_id)

      return db_class
    else
      return nil
    end
  end

  def delete_user_class(classId)
    user_class = UserClass.find(classId)
    userId = user_class.user_id
    time_unit_id = user_class.time_unit_id

    if user_class.destroy()
      user_gpa = DomainUserGpa.new(
        UserGpaService.new.calculate_gpa(userId, time_unit_id)
      )
      return {:status => true, :user_gpa => user_gpa}
    else
      return {:status => false}
    end
  end

  private
  def get_gpa(grade)
    case grade
      when 'A'
        gpa = 4.0
      when 'A-'
        gpa = 3.67
      when 'B+'
        gpa = 3.33
      when 'B'
        gpa = 3.00
      when 'B-'
        gpa = 2.67
      when 'C+'
        gpa = 2.33
      when 'C'
        gpa = 2.00
      when 'C-'
        gpa = 1.67
      when 'D+'
        gpa = 1.33
      when 'D'
        gpa = 1.00
      when 'D-'
        gpa = 0.67
      when 'F'
        gpa = 0.0
    end

    return gpa
  end

  # TODO I'm thinking we can eventually pass in a scale object that will have
  # an upper and lower bounds for each grade, then set the ranges using that
  private
  def get_grade(grade_value)
    case grade_value
      when 92.5..100
        grade = 'A'
      when 89.5..92.4
        grade = 'A-'
      when 86.5..89.4
        grade = 'B+'
      when 82.5..86.4
        grade = 'B'
      when 79.5..82.4
        grade = 'B-'
      when 76.5..79.4
        grade = 'C+'
      when 72.5..76.4
        grade = 'C'
      when 69.5..72.4
        grade = 'C-'
      when 66.5..69.4
        grade = 'D+'
      when 62.5..66.4
        grade = 'D'
      when 59.5..62.4
        grade = 'D-'
      when 0..59.4
        grade = 'F'
    end

    return grade
  end

end
