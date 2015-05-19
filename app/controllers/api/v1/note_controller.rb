class Api::V1::NoteController < ApplicationController
  respond_to :json

  before_filter :load_services

  def load_services( noteService = nil, userRepo = nil )
    @noteService = noteService ? noteService : NoteService.new
    @userRepo = userRepo ? userRepo : UserRepository.new
  end

  # GET /users/:user_id/note
  def index
    userId = params[:user_id].to_i
    user = @userRepository.get_user(userId)

    if !can?(current_user, :note_read_create, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @noteService.get_notes(current_user, userId)

    render status: result.status,
      json: {
        info: result.info,
        notes: result.object
      }
  end

  # POST /users/:user_id/note
  def create
    userId = params[:user_id].to_i
    note = params[:note]
    user = @userRepository.get_user(userId)

    if !can?(current_user, :note_read_create, user)
      render status: :forbidden,
        json: {}
      return
    end

    result = @noteService.create_note(note)

    render status: result.status,
      json: {
        info: result.info,
        note: result.object
      }

  end

  # PUT /note/:id
  def update
    note = params[:note]

    if (note[:created_by].to_i != current_user.id)
      render status: :forbidden,
        json: {}
      return
    end

    result = @noteService.update_note(note)

    render status: result.status,
      json: {
        info: result.info,
        note: result.object
      }

  end

  # DELETE /note/:id
  def destroy
    noteId = params[:id].to_i
    note = params[:note]

    if (note[:created_by].to_i != current_user.id)
      render status: :forbidden,
        json: {}
      return
    end

    result = @noteService.delete_note(noteId)

    render status: result.status,
      json: {
        info: result.info
      }

  end

end
