class OrganizationService

  def get_time_units(orgId)
    timeUnits = TimeUnit.where(:organization_id => orgId).order(:id)
    return timeUnits.map{|tu| DomainTimeUnit.new(tu)} unless timeUnits.nil?
  end

  def get_organizations(filters, selects = {})
    # TODO Authentication
    filters[:id] = filters[:organization_id] unless filters[:organization_id].nil?
    applicable_filters = FilterFactory.new.conditions(Organization.column_names.map(&:to_sym), filters)
    orgs = Organization.find(:all, :conditions => applicable_filters)
    return orgs
    #return orgs.map{|o| DomainOrganization.new(o, selects)}
  end

end
