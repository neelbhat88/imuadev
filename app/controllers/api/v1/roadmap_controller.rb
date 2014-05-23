class Api::V1::RoadmapController < ApplicationController

  before_filter :authenticate_user!
  skip_before_filter  :verify_authenticity_token

  respond_to :json

  # POST roadmap
  def create
    orgId = params[:roadmap][:organization_id].to_i
    name = params[:roadmap][:name]
    desc = params[:roadmap][:description]

    roadmap = {
                :organization_id => orgId,
                :name => name,
                :description => desc
              }

    result = RoadmapRepository.new.create_roadmap(roadmap)

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

    render status: 200,
      json: {
        success: result[:success],
        info: result[:info],
        time_unit: ViewTimeUnit.new(result[:time_unit])
      }
  end

  # PUT /time_unit/:id
  def update_time_unit
    time_unit = params[:time_unit]

    result = RoadmapRepository.new.update_time_unit(time_unit)

    render status: 200,
      json: {
        success: result[:success],
        info: result[:info],
        time_unit: ViewTimeUnit.new(result[:time_unit])
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

  # POST /milestone
  def create_milestone
    tuId = params[:milestone][:time_unit_id]
    mod = params[:milestone][:module]
    submod = params[:milestone][:submodule]
    importance = params[:milestone][:importance]
    title = params[:milestone][:title]
    desc = params[:milestone][:description]
    is_default = params[:milestone][:is_default]
    levels = params[:milestone][:milestone_levels] # Array of values e.g. ['3.25', '3.5'] or ['Math|2', 'History|1']

    milestone = { :module => mod, :submodule=> submod, :importance => importance,
                  :title => title, :description => desc, :milestone_levels => levels, :time_unit_id => tuId,
                  :is_default => is_default }

    result = RoadmapRepository.new.create_milestone(milestone)

    render status: 200,
      json: {
        success: result[:success],
        info: result[:info],
        milestone: ViewMilestone.new(result[:milestone])
      }
  end

end