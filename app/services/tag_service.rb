class TagService

  def get_org_tags(orgId)
    org = Organization.find(orgId)
    owned_tags = org.owned_tags
    org_tags = []
    owned_tags.each do |o|
      org_tags << o.name
    end

    return ReturnObject.new(:ok, "Tags for #{org.name}", org_tags)
  end

  def get_user_tags(userId)
    user = User.find(userId)
    org = Organization.find(user.organization_id)
    user_tags = user.tags_from(org)

    return ReturnObject.new(:ok, "Tags for #{user.first_name} #{user.last_name}", user_tags)
  end

  def create_user_tag(userId, tag)
    user = User.find(userId)
    org = Organization.find(user.organization_id)
    tags = user.tags_from(org)
    tags = tags << tag

    org.tag(user, :with => tags, :on => :tags)

    return ReturnObject.new(:ok, "Created tag for #{user.first_name} #{user.last_name}", tag)
  end

  def create_users_tag(orgId, users, tag)
    org = Organization.find(orgId)
    users.each do |u|
      user = User.find(u[:id])
      tags = user.tags_from(org)
      tags = tags << tag
      org.tag(user, :with => tags, :on => :tags)
    end

    return ReturnObject.new(:ok, "Created tag for users", tag)
  end

  def remove_user_tag(userId, tag)
    user = User.find(userId)
    org = Organization.find(user.organization_id)

    user.tags_from(org).remove(tag)
    if user.save
      tags = user.tags_from(org)
      return ReturnObject.new(:ok, "Removed #{tag} from #{user.first_name}", tags)
    else
      return ReturnObject.new(:internal_server_error, "Failed to delete #{tag} for #{user.first_name}", nil)
    end
  end

  def remove_users_tag(orgId, users, tag)
    org = Organization.find(orgId)

    users.each do |u|
      user = User.find(u[:id])
      user.tags_from(org).remove(tag)
      user.save
    end

    return ReturnObject.new(:ok, "Deleted #{tag}", tag)
  end

end
