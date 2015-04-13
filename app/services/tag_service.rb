class TagService

  def get_org_tags(orgId)
    org = Organization.find(orgId)
    org_tags = org.owned_tags

    return ReturnObject.new(:ok, "Tags for #{org.name}", org_tags)
  end

  def get_user_tags(userId)
    user = User.find(userId)
    user_tags = user.tag_list

    return ReturnObject.new(:ok, "Tags for #{user.first_name} #{user.last_name}", user_tags)
  end

  def create_user_tag(userId)
  end

  def create_users_tag(orgId)
  end

  def remove_user_tag(userId)
  end

  def remove_users_tag(orgId)
  end

end
