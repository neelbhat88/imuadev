class Api::V1::RoadmapController < ApplicationController

  before_filter :authenticate_token
  skip_before_filter :verify_authenticity_token
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

end
