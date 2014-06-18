class Api::V1::ProgressController < ApplicationController

  before_filter :authenticate_user!
  skip_before_filter  :verify_authenticity_token

  respond_to :json

  # GET /progress/modules
  # Returns All modules for a students current semester and the
  # total points avaiable in each module and the user's points earned
  def all_modules_progress
    userId = params[:user_id]
    orgId = params[:organization_id]
    time_unit_id = params[:time_unit_id]

    enabled_modules = EnabledModules.new.get_modules(orgId)

    modules_progress = []
    enabled_modules.each do | m |

      m.submodules.each do | sm |
        total_points = sm.total_milestone_points(time_unit_id)
        user_points = sm.total_user_points(userId, time_unit_id)

        modObj = {:module_title => m.title, :points=>{:total=>total_points, :user=>user_points} }
        modules_progress << modObj
      end
    end

    render status: 200,
      json: {
        info: "Module progress points",
        modules_progress: modules_progress
      }
  end

  # GET /user/:id/data/academics/:time_unit_id
  def user_academics_data
    userId = params[:id]
    time_unit_id = params[:time_unit_id]

    classes = ProgressRepository.new.get_user_classes(userId, time_unit_id)

    render status: 200,
      json: {
        info: "User's academics data",
        academics_data: classes
      }
  end
end