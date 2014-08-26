class Api::V1::AssignmentController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :load_services

  def load_services( assignmentService = nil )
    @assignmentService = assignmentService ? assignmentService : AssignmentService.new
  end

  # GET /users/:id/assignments
  # Returns all Assignments for the given User
  def index
    userId = params[:user_id]

    result = @assignmentService.get_assignments(userId)

    render status: :ok,
      json: {
        info: "assignments",
        assignments: result
      }
  end

  # POST /users/:id/assignments
  # Creates an Assignment for the given User
  def create
    userId     = params[:user_id].to_i
    assignment = params[:assignment]

    assignment["user_id"] = userId

    result = @assignmentService.create_assignment(assignment)

    render status: result.status,
      json: {
        info: result.info,
        assignment: result.object
      }
  end

  # PUT /assignments/:id
  # Updates an Assignment for the given User
  def update
    assignmentId = params[:id].to_i
    assignment   = params[:assignment]

    assignment["id"] = assignmentId

    result = @assignmentService.update_assignment(assignment)

    render status: result.status,
      json: {
        info: result.info,
        assignment: result.object
      }
  end

  # DELETE /assignments/:id
  # Deletes an Assignment for the given User
  def destroy
    assignmentId = params[:id].to_i

    result = @assignmentService.delete_assignment(assignmentId)

    render status: result.status,
      json: {
        info: result.info
      }
  end

end
