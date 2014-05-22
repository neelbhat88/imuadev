class Api::V1::RoadmapController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter  :verify_authenticity_token

  respond_to :json

  # GET /organization/:id/roadmap
  def show
    orgId = params[:id].to_i

    roadmap = RoadmapRepository.new.get_roadmap_by_organization(orgId)

    render status: 200,
      json: {
        success: true,
        info: "Roadmap",
        roadmap: roadmap
      }
  end

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

  # POST milestone
  def create_milestone
    tuId = params[:milestone][:time_unit_id]
    mod = params[:milestone][:module]
    submod = params[:milestone][:submodule]
    importance = params[:milestone][:importance]
    title = params[:milestone][:title]
    desc = params[:milestone][:description]
    levels = params[:milestone][:levels] # Array of values e.g. ['3.25', '3.5'] or ['Math|2', 'History|1']

    milestone = { :module => mod, :submodule=> submod, :importance => importance,
                  :title => title, :description => desc, :levels => levels, :time_unit_id => tuId }

    result = RoadmapRepository.new.create_milestone(milestone)

    render status: 200,
      json: {
        success: result[:success],
        info: result[:info],
        milestone: ViewMilestone.new(result[:milestone])
      }
  end

end

class RoadmapRepository
  def initialize
  end

  def get_roadmap_by_organization(orgId)
    roadmap = Roadmap.where(:organization_id => orgId)[0]

    return ViewRoadmap.new(roadmap)
  end

  def create_roadmap(roadmap)
    if Roadmap.where(:organization_id => roadmap[:organization_id]).length != 0
      return { :success => false, :info => "Roadmap for the organization already exists.", :roadmap => nil }
    end

    newroadmap = Roadmap.new do | r |
      r.name = roadmap[:name]
      r.description = roadmap[:description], 
      r.organization_id = roadmap[:organization_id]
    end

    if newroadmap.save
      return { :success => true, :info => "Roadmap created successfully.", :roadmap => newroadmap }
    end

    return { :success => false, :info => "Failed to create roadmap.", :roadmap => nil }

  end

  def create_time_unit(time_unit)
    roadmap = Roadmap.find(time_unit[:roadmap_id])
    
    new_time_unit = roadmap.time_units.new do | tu |
      tu.name = time_unit[:name]
      tu.organization_id = time_unit[:organization_id]
    end

    if new_time_unit.save
      return { :success => true, :info => "Time unit created successfully.", :time_unit => new_time_unit }
    else
      return { :success => false, :info => "Failed to create time unit.", :time_unit => nil }
    end
  end

  def update_time_unit(time_unit)
    result = TimeUnit.find(time_unit[:id]).update_attributes(:name => time_unit[:name])

    if result 
      new_time_unit = TimeUnit.find(time_unit[:id])

      return { :success => true, :info => "Successfully updated Time Unit id:#{time_unit[:id]}.", :time_unit => new_time_unit }
    else
      old_time_unit = TimeUnit.find(time_unit[:id])

      return { :success => false, :info => "Failed to update Time Unit id:#{time_unit[:id]}.", :time_unit => old_time_unit }
    end
  end

  def delete_time_unit(time_unit_id)
    if TimeUnit.find(time_unit_id).destroy()
      return { :success => true, :info => "Successfully deleted Time Unit id:#{time_unit_id} and all of its milestones." }
    else
      return { :success => false, :info => "Failed to delete Time Unit id:#{time_unit_id}." }
    end
  end

  def create_milestone(milestone)
    default_points = 10

    time_unit = TimeUnit.find(milestone[:time_unit_id])

    newmilestone = time_unit.milestones.new do | m |
      m.module = milestone[:module]
      m.submodule = milestone[:submodule]
      m.importance = milestone[:importance]
      m.points = default_points
      m.title = milestone[:title]
      m.description = milestone[:description]

      milestone[:levels].each do | l |
        m.milestone_levels.new do | ml |
          ml.value = l
        end
      end
    end

    if newmilestone.save
      return { :success => true, :info => "Milestone created successfully.", :milestone => newmilestone }
    else
      return { :success => false, :info => "Failed to create milestone.", :milestone => nil }
    end

  end

end