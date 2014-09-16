class OrganizationService

  def get_time_units(orgId)
    timeUnits = TimeUnit.where(:organization_id => orgId).order(:id)
    return timeUnits.map{|tu| DomainTimeUnit.new(tu)} unless timeUnits.nil?
  end

end
