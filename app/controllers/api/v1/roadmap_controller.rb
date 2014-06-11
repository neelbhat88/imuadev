class Api::V1::RoadmapController < ApplicationController

  before_filter :authenticate_user!
  skip_before_filter  :verify_authenticity_token

  respond_to :json

  # POST /roadmap
  def create
    orgId = params[:roadmap][:organization_id].to_i
    name = params[:roadmap][:name]

    roadmap = {
                :organization_id => orgId,
                :name => name
              }

    result = RoadmapRepository.new.create_roadmap_with_semesters(roadmap)

    viewRoadmap = ViewRoadmap.new(result[:roadmap]) unless result[:roadmap].nil?
    render status: 200,
      json: {
        success: result[:success],
        info: result[:info],
        roadmap: viewRoadmap
      }

  end

  # PUT /roadmap/:id
  def update
    roadmap = params[:roadmap]

    result = RoadmapRepository.new.update_roadmap(roadmap)

    viewRoadmap = ViewRoadmap.new(result[:roadmap]) unless result[:roadmap].nil?
    render result[:status],
      json: {
        info: result[:info],
        roadmap: viewRoadmap
      }
  end

  # DELETE /roadmap/:id
  def delete
    roadmapId = params[:id]

    result = RoadmapRepository.new.delete_roadmap(roadmapId)

    render status: 200,
      json: {
        success: result[:success],
        info: result[:info]
      }
  end

  # POST /time_unit
  def create_time_unit
    orgId = params[:time_unit][:organization_id].to_i
    rId = params[:time_unit][:roadmap_id].to_i
    name = params[:time_unit][:name]

    time_unit = {
                :organization_id => orgId,
                :name => name,
                :roadmap_id => rId
              }

    result = RoadmapRepository.new.create_time_unit(time_unit)

    viewTimeUnit = ViewTimeUnit.new(result[:time_unit]) unless result[:time_unit].nil?
    render status: 200,
      json: {
        success: result[:success],
        info: result[:info],
        time_unit: viewTimeUnit
      }
  end

  # PUT /time_unit/:id
  def update_time_unit
    time_unit = params[:time_unit]

    result = RoadmapRepository.new.update_time_unit(time_unit)

    viewTimeUnit = ViewTimeUnit.new(result[:time_unit]) unless result[:time_unit].nil?
    render status: 200,
      json: {
        success: result[:success],
        info: result[:info],
        time_unit: viewTimeUnit
      }
  end

  # DELETE /time_unit/:id
  def delete_time_unit
    tuId = params[:id]

    result = RoadmapRepository.new.delete_time_unit(tuId)

    render status: 200,
      json: {
        success: result[:success],
        info: result[:info]
      }
  end

  # GET /milestone/default/:module/:submodule
  def default_milestone
    mod = params[:module]
    submod = params[:submodule]

    milestone = RoadmapRepository.new.get_default_milestone({ :module => mod, :submodule=> submod })

    viewMilestone = ViewMilestone.new(milestone) unless milestone.nil?
    render status: 200,
      json: {
        success: true,
        info: "Default milestone",
        milestone: viewMilestone
      }
  end

  # POST /milestone
  def create_milestone
    tuId = params[:milestone][:time_unit_id]
    mod = params[:milestone][:module]
    submod = params[:milestone][:submodule]
    importance = params[:milestone][:importance]
    title = params[:milestone][:title]
    desc = params[:milestone][:description]
    is_default = params[:milestone][:is_default]
    value = params[:milestone][:value]

    milestone = { :module => mod, :submodule=> submod, :importance => importance,
                  :title => title, :description => desc, :value => value, :time_unit_id => tuId,
                  :is_default => is_default }

    result = RoadmapRepository.new.create_milestone(milestone)

    viewMilestone = ViewMilestone.new(result[:milestone]) unless result[:milestone].nil?
    render status: 200,
      json: {
        success: result[:success],
        info: result[:info],
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

    result = RoadmapRepository.new.update_milestone(milestone)

    viewMilestone = ViewMilestone.new(result[:milestone]) unless result[:milestone].nil?
    render status: 200,
      json: {
        success: result[:success],
        info: result[:info],
        milestone: viewMilestone
      }
  end

  # DELETE /milestone/:id
  def delete_milestone
    milestoneId = params[:id]

    result = RoadmapRepository.new.delete_milestone(milestoneId)

    render status: 200,
      json: {
        success: result[:success],
        info: result[:info]
      }
  end

end