class OrganizationRepository

  def get_all_organizations
    orgs = Organization.all

    return { :success => true, :info => "All organizations", :organizations => orgs }
  end

  def get_organization(orgId)
    org = Organization.find(orgId)

    return { :success => true, :info => "Organization id:#{orgId}", :orgnization => org }
  end

  def create_organization(opts)
    name = opts[:name]

    if Organization.where(:name => name).length != 0
      return { :success => false, :info => "Organization with the name #{name} already exists" }
    end

    organization = Organization.new
    organization.name = name

    if organization.save
      return { :success => true, :info => "Organization created successfully", :organization => organization }
    end

    return { :success => false, :info => "Failed to create organization", :organization => nil }
  end

  def update_organization(organization)
    org = Organization.find(organization[:id])

    if !org.nil? && org.update_attributes(:name => organization[:name])
      return { :success => true, :info => "Successfully updated Organization id:#{organization[:id]}.", :organization => org }
    else
      return { :success => false, :info => "Failed to update Organization id:#{organization[:id]}.", :organization => org }
    end
  end

  def delete_organization(orgId)
    if Organization.find(orgId).destroy()
      return { :success => true, :info => "Successfully deleted Organization id:#{orgId}." }
    else
      return { :success => false, :info => "Failed to delete Organization id:#{orgId}." }
    end
  end

end