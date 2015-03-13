class Api::V1::AssignmentController < ApplicationController
  respond_to :json

  before_filter :authenticate_token
  skip_before_filter :verify_authenticity_token
  before_filter :load_services

  def load_services( assignmentService = nil )
    @assignmentService = assignmentService ? assignmentService : AssignmentService.new(current_user)
  end

  # PUT /assignment/:id
  # Updates an Assignment
  def update
    assignmentId = params[:id].to_i
    assignment   = params[:assignment]

    assignment["id"] = assignmentId

    if !can?(current_user, :update_assignment, Assignment.where(id: params[:id]).first)
      render status: :forbidden, json: {}
      return
    end

    result = @assignmentService.update(assignment)

    render status: result.status,
      json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  end

  # DELETE /assignment/:id
  # Deletes an Assignment
  def destroy
    assignmentId = params[:id].to_i

    if !can?(current_user, :destroy_assignment, Assignment.where(id: params[:id]).first)
      render status: :forbidden, json: {}
      return
    end

    result = @assignmentService.destroy(assignmentId)

    render status: result.status,
      json: Oj.dump( { info: result.info }, mode: :compat)
  end

  # GET /assignment/:id/collection
  # Returns the Assignment with its collection of UserAssignments
  def collection
    url_params = params.except(*[:id, :controller, :action]).symbolize_keys
    url_params[:assignment_id] = params[:id]

    if !can?(current_user, :get_assignment_collection, Assignment.where(id: params[:id]).first)
      render status: :forbidden, json: {}
      return
    end

    result = @assignmentService.get_collection(url_params)

    render status: result.status,
      json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  end

  # PUT /assignment/:id/broadcast
  # Updates an Assignment and its collection of UserAssignments
  def broadcast
    url_params = params.except(*[:id, :controller, :action]).symbolize_keys
    url_params[:assignment_id] = params[:id]

    # TODO Fix to incorporate authorizations for updating all the user_assignments
    if !can?(current_user, :update_assignment_broadcast, Assignment.where(id: params[:id]).first)
      render status: :forbidden, json: {}
      return
    end

    result = @assignmentService.update_broadcast(url_params)

    render status: result.status,
      json: Oj.dump( { info: result.info, organization: result.object }, mode: :compat)
  end

end
