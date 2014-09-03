class Api::V1::UserAssignmentController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :load_services

  def load_services( assignmentService = nil )
    @assignmentService = assignmentService ? assignmentService : AssignmentService.new
  end
  # GET /users/:user_id/user_assignment
  # Returns all UserAssignments for the given User
  def index
    userId = params[:user_id]

    result = @assignmentService.get_user_assignments(userId)

    render status: :ok,
      json: {
        info: "user_assignments",
        user_assignments: result
      }
  end

  # POST /users/:user_id/user_assignment
  # Creates a UserAssignment for the given User
  def create
    userId         = params[:user_id].to_i
    userAssignment = params[:user_assignment]

    userAssignment["user_id"] = userId

    result = @assignmentService.create_user_assignment(userAssignment)

    render status: result.status,
      json: {
        info: result.info,
        user_assignment: result.object
      }
  end

  # PUT /user_assignment/:id
  # Updates a UserAssignment
  def update
    userAssignmentId = params[:id].to_i
    userAssignment   = params[:user_assignment]

    userAssignment["id"] = userAssignmentId

    result = @assignmentService.update_user_assignment(userAssignment)

    render status: result.status,
      json: {
        info: result.info,
        user_assignment: result.object
      }
  end

  # DELETE /user_assignment/:id
  # Deletes a UserAssignment
  def destroy
    userAssignmentId = params[:id].to_i

    result = @assignmentService.delete_user_assignment(userAssignmentId)

    render status: result.status,
      json: {
        info: result.info,
      }
  end

  # GET /user_assignment/:id/collect
  # Returns the UserAssignment with associated Assignment data
  def collect
    userAssignmentId = params[:id].to_i

    result = @assignmentService.collect_user_assignment(userAssignmentId)
    viewUserAssignment = ViewUserAssignment.new(result, {assignment: true})

    render status: :ok,
      json: {
        info: "UserAssignment id: #{userAssignmentId}.",
        user_assignment: viewUserAssignment
      }
  end

  # GET /users/:user_id/assignment/collect
  # Returns all of a User's UserAssignments with their associated Assignment data
  def collect_all
    userId = params[:user_id].to_i

    results = @assignmentService.collect_user_assignments(userId)
    viewUserAssignments = results.map{|r| ViewUserAssignment.new(r)}

    render status: :ok,
      json: {
        info: "UserAssignments for use id: #{userId}.",
        user_assignments: viewUserAssignments
      }
  end

end
