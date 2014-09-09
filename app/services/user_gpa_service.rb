class UserGpaService
  # calculate methods are separate, and currently only using the regular unweighted calculation
  # will move returning the values and making one save/update with all calc'd gpas

#  def calculate_regular_weighted
#  end

  def calculate_regular_unweighted(userId, time_unit_id)
    classes = UserClassService.new.get_user_classes(userId, time_unit_id)

    totalGpa = 0.0
    totalClassCredits = 0.0
    classes.each do | c |
      totalGpa += (c.gpa * c.credit_hours)
      totalClassCredits += c.credit_hours
    end

    calculatedGpa = (totalGpa / totalClassCredits).round(2)

    db_class = UserGpa.where(:user_id => userId, :time_unit_id => time_unit_id).first

    if db_class
      db_class.update_attributes(
        :user_id => userId,
        :time_unit_id => time_unit_id,
        :regular_unweighted => calculatedGpa
      )
      return db_class
    elsif !calculatedGpa.nan?
      new_user_gpa = UserGpa.new do |u|
        u.user_id = userId
        u.time_unit_id = time_unit_id
        u.regular_unweighted = calculatedGpa
      end

      new_user_gpa.save
      return new_user_gpa
    end

  end

#  def calculate_core_weighted
#  end

#  def calculate_core_unweighted
#  end

  def get_user_gpa(userId, time_unit_id)
    user_gpa = UserGpa.where(:user_id => userId, :time_unit_id => time_unit_id).first
    return DomainUserGpa.new(user_gpa) unless user_gpa.nil?
  end

  def get_user_gpas(userId)
    user_gpas = UserGpa.where(:user_id => userId)
    return user_gpas.map{|ug| DomainUserGpa.new(ug)} unless user_gpas.empty?
  end

end
