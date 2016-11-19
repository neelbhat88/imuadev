class OrganizationRepository

  def get_all_organizations
    orgs = Organization.all

    return ReturnObject.new(:ok, "All organizations", orgs)
  end

  def get_organization(orgId)
    return Organization.where(:id => orgId)[0] #Not using find here because of the exception it throws when not found
  end

  def create_organization(opts)
    name = opts[:name]

    if Organization.where(:name => name).length != 0
      return { status: :bad_request, :success => false, :info => "Organization with the name #{name} already exists" }
    end

    organization = Organization.new
    organization.name = name

    if organization.save
      roadmap = {
                :organization_id => organization.id,
                :name => organization.name + "'s Roadmap"
              }

      result = RoadmapRepository.new.create_roadmap_with_semesters(roadmap)
      if !result[:success]
        return { :success => false, :info => "Organization created successfully BUT failed to create default roadmap.", :organization => organization }
      end

      return { :success => true, :info => "Organization created successfully. Default roadmap created for organization.", :organization => organization }
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
