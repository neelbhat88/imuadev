class Api::V1::MilestoneController < ApplicationController

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  respond_to :json

  # GET /milestone/:id/status
  def get_milestone_status
    url_params = params.except(*[:id, :controller, :action]).symbolize_keys
    url_params[:milestone_id] = params[:id]

    # TODO - Abilities for Milestone subjectObj?
    # if !can?(current_user, :get_milestone_status, Milestone.where(id: params[:id]).first)
    #   render status: :forbidden, json: {}
    #   return
    # end

    result = MilestoneService.new.get_milestone_status(url_params)

    render status: result.status,
      json: Oj.dump({ info: result.info, organization: result.object }, mode: :compat)
  end

  # POST /milestone
  def create_milestone
    tuId = params[:milestone][:time_unit_id]
    mod = params[:milestone][:module]
    submod = params[:milestone][:submodule]
    importance = params[:milestone][:importance]
    points = params[:milestone][:points]
    title = params[:milestone][:title]
    desc = params[:milestone][:description]
    is_default = params[:milestone][:is_default]
    value = params[:milestone][:value]
    icon = params[:milestone][:icon]

    milestone = { :module => mod, :submodule=> submod, :importance => importance, :points => points,
                  :title => title, :description => desc, :value => value, :time_unit_id => tuId,
                  :is_default => is_default, :icon => icon, :organization_id => current_user.organization_id }

    result = MilestoneService.new.create_milestone(milestone)

    viewMilestone = ViewMilestone.new(result.object) unless result.object.nil?
    render status: result.status,
      json: {
        info: result.info,
        milestone: viewMilestone
      }
  end

  # PUT /milestone/:id
  def update_milestone
    milestoneId = params[:id]
    milestone = params[:milestone]

    if milestone[:id].nil?
      milestone[:id] = milestoneId
    end

    result = MilestoneService.new.update_milestone(milestone)

    viewMilestone = ViewMilestone.new(result.object) unless result.object.nil?
    render status: result.status,
      json: {
        info: result.info,
        milestone: viewMilestone
      }
  end

  # DELETE /milestone/:id
  def delete_milestone
    milestoneId = params[:id]

    result = MilestoneService.new.delete_milestone(milestoneId)

    render status: result.status,
      json: {
        info: result.info
      }
  end

  # Temporary method to update all milestone org_ids
  # GET /milestone/update_org_id
  def update_org_id
    Milestone.all.each do | m |
      m.update_attributes(:organization_id => m.time_unit.organization_id)
    end

    render status: :ok,
      json: {
        info: "Updated all milestones"
      }
  end
end
