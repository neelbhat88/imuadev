class Api::V1::AssignmentController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :load_services

  def load_services( assignmentService = nil )
    @assignmentService = assignmentService ? assignmentService : AssignmentService.new
  end

  # GET /users/:user_id/assignment
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

  # GET /assignment/:id
  # Returns the Assignment
  def show
    assignmentId = params[:id]

    result = @assignmentService.get_assignment(assignmentId)

    render status: :ok,
      json: {
        info: "assignment",
        assignments: result
      }
  end

  # POST /users/:user_id/assignment
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

  # PUT /assignment/:id
  # Updates an Assignment
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

  # DELETE /assignment/:id
  # Deletes an Assignment
  def destroy
    assignmentId = params[:id].to_i

    result = @assignmentService.delete_assignment(assignmentId)

    render status: result.status,
      json: {
        info: result.info
      }
  end

  # GET /assignment/:id/collect
  # Returns the Assignment with its collection of UserAssignments
  def collect
    assignmentId = params[:id].to_i

    result = @assignmentService.collect_assignment(assignmentId)

    render status: :ok
      json: {
        info: "Assignment id: #{assignmentId} collection.",
        assignment_collection: result.object
      }

  end

  # GET /users/:user_id/assignment/collect
  # Returns all of a User's Assignments with their collections of UserAssignments
  def collect_all
    userId = params[:user_id].to_i

    result = @assignmentService.collect_assignments(userId)

    render status: :ok
      json: {
        info: "Assignment collection, user id: #{userId}.",
        assignment_collections: result.object
      }

  end

  # POST /users/:user_id/assignment/broadcast
  # Creates an Assignment and its collection of User Assignments
  def broadcast
    userId = params[:user_id].to_i
    assignment = params[:assignment]
    user_assignments = params[:user_assignments]

    assignment.user_id = userId
    assignmentResult = @assignmentService.create_assignment(assignment)

    userAssignmentResults = []
    if assignmentResult.status :ok
      user_assignments.each do |a|
        a.assignment_id = assignmentResult.object.id
        userAssignmentResults << @assignmentService.create_user_assignment(a)
      end
    end

    # TODO What if a userAssignment operation fails?

    assignmentResult.object.user_assignment_results = userAssignmentResults
    render status: assignmentResult.status,
      json: {
        info: assignmentResult.info,
        assignment_broadcast_result: assignmentResult.object
      }
  end

  # PUT /assignment/:id/broadcast
  # Updates an Assignment and its collection of UserAssignments
  def broadcast_update
    assignmentId = params[:id].to_i
    assignment = params[:assignment]
    user_assignments = params[:user_assignments]

    assignment.id = assignmentId
    assignmentResult = @assignmentService.update_assignment(assignment)

    userAssignmentResults = []
    if assignmentResult.status :ok
      user_assignments.each do |a|
        a.assignment_id = assignmentResult.object.id
        userAssignmentResults << (a.id.nil?) ? @assignmentService.create_user_assignment(a) :
                                               @assignmentService.update_user_assignment(a)
      end
    end

    # TODO What if a userAssignment operation fails?

    assignmentResult.object.user_assignment_results = userAssignmentResults
    render status: assignmentResult.status,
      json: {
        info: assignmentResult.info,
        assignment_broadcast_result: assignmentResult.object
      }
  end

end
