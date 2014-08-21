class UserClassService

  def get_user_classes(userId, time_unit_id)
    if time_unit_id == 0
      return UserClass.where(:user_id => userId).order(:id)
    end

    return UserClass.where(:user_id => userId, :time_unit_id => time_unit_id).order(:id)
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

  def save_user_class(userId, user_class)
    new_class = UserClass.new do | u |
      u.user_id = userId
      u.name = user_class[:name]
      u.grade = user_class[:grade]
      u.gpa = get_gpa(user_class[:grade])
      u.time_unit_id = user_class[:time_unit_id]
      u.period = user_class[:period]
      u.room = user_class[:room]
      u.credit_hours = user_class[:credit_hours] ? user_class[:credit_hours] : 1
      u.level = user_class[:level] ? user_class[:level] : Constants.ClassLevels[:REGULAR]
      u.subject = user_class[:subject]
    end

    if new_class.save
      return ReturnObject.new(:ok, "User class created successfully", new_class)
    else
      return ReturnObject.new(:bad_request, "Failed to create a user class", nil)
    end
  end

  def update_user_class(user_class)
    db_class = UserClass.find(user_class[:id])

    if db_class.update_attributes(:name => user_class[:name],
                                  :grade => user_class[:grade],
                                  :gpa => get_gpa(user_class[:grade]),
                                  :period => user_class[:period],
                                  :room => user_class[:room],
                                  :credit_hours => user_class[:credit_hours],
                                  :level => user_class[:level],
                                  :subject => user_class[:subject]
                                 )
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

end
