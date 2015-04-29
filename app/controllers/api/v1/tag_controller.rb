class Api::V1::TagController < ApplicationController
  respond_to :json

  before_filter :load_services

  def load_services( userRepo = nil, tagService = nil )
    @userRepository = userRepo ? userRepo : UserRepository.new
    @tagService = tagService ? tagService : TagService.new
  end

  def index
    orgId = params[:organization_id].to_i

    if !can?(current_user, :read_tags, Organization.find(orgId))
      render status: :forbidden, json: {}
      return
    end

    result = @tagService.get_org_tags(orgId)

    render status: result.status,
      json: {
        info: result.info,
        tags: result.object
      }
  end

  def add_users_tag
    orgId = params[:id].to_i
    users = params[:users]
    tag = params[:tag]

    if !can?(current_user, :edit_tags, Organization.find(orgId))
      render status: :forbidden, json: {}
      return
    end

    result = @tagService.create_users_tag(orgId, users, tag)

    render status: result.status,
    json: {
      info: result.info,
      tag: result.object
    }
  end

  def delete_users_tag
    orgId = params[:id].to_i
    users = params[:users]
    tag = params[:tag]

    if !can?(current_user, :edit_tags, Organization.find(orgId))
      render status: :forbidden, json: {}
      return
    end

    result = @tagService.remove_users_tag(orgId, users, tag)

    render status: result.status,
    json: {
      info: result.info
    }
  end

end
