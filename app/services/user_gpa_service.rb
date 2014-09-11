class UserGpaService
  # calculate methods are separate, and currently only using the regular unweighted calculation
  # will move returning the values and making one save/update with all calc'd gpas

#  def calculate_regular_weighted
#  end

  def calculate_regular_unweighted(userId, time_unit_id)
    classes = UserClassService.new.get_user_classes(userId, time_unit_id)

    if !classes.empty?
      totalGpa = 0.0
      totalClassCredits = 0.0
      classes.each do | c |
        totalGpa += (c.gpa * c.credit_hours)
        totalClassCredits += c.credit_hours
      end

      return (totalGpa / totalClassCredits).round(2)
    else
      return 0
    end

  end

#  def calculate_core_weighted
#  end

#  def calculate_core_unweighted
#  end

  def calculate_gpa(userId, time_unit_id)
    db_gpa = UserGpa.where(:user_id => userId, :time_unit_id => time_unit_id).first

    regular_unweighted = calculate_regular_unweighted(userId, time_unit_id)

    if db_gpa
      db_gpa.update_attributes(
        :user_id => userId,
        :time_unit_id => time_unit_id,
        :regular_unweighted => regular_unweighted
      )

      UserGpaHistoryService.new.create_gpa_history(db_gpa)
      return db_gpa

    else
      new_user_gpa = UserGpa.new do |u|
        u.user_id = userId
        u.time_unit_id = time_unit_id
        u.regular_unweighted = regular_unweighted
      end

      new_user_gpa.save
      UserGpaHistoryService.new.create_gpa_history(new_user_gpa)

      return new_user_gpa
    end

  end

  def get_user_gpa(userId, time_unit_id)
    user_gpa = UserGpa.where(:user_id => userId, :time_unit_id => time_unit_id).first
    return DomainUserGpa.new(user_gpa) unless user_gpa.nil?
  end

  def get_user_gpas(userId)
    user_gpas = UserGpa.where(:user_id => userId)
    return user_gpas.map{|ug| DomainUserGpa.new(ug)} unless user_gpas.empty?
  end

end
