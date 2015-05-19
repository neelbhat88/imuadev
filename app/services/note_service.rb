class NoteService

  def get_notes(current_user, userId)
    if current_user.mentor?
      notes = Note.where("user_id = ? AND (created_by = ? OR is_private = ?)",
                         userId, current_user.id, false
                        ).order("date DESC")
    else
      notes = Note.where(:user_id => userId).order("date DESC")
    end

    return ReturnObject.new(:ok, "Displayable notes found", notes)
  end

  def save_note(note)
    new_note = Note.new do | n |
      n.user_id =    note[:user_id]
      n.created_by = note[:current_user_id]
      n.message =    note[:message]
      n.note_type =  note[:note_type]
      n.date =       note[:date]
      n.time_spent = note[:time_spent]
      n.is_private = note[:is_private]
    end

    if new_note.save
      return ReturnObject.new(:ok, "Successfully created new note", new_note)
    else
      return ReturnObject.new(:internal_server_error, "Failed to create note. Errors: #{new_note.errors.inspect}", nil)
    end

  end

  def update_note(note)
    db_note = Note.find(note[:id].to_i)

    if db_note.update_attributes(:message    => note[:message],
                                 :note_type  => note[:note_type],
                                 :date       => note[:date],
                                 :time_spent => note[:time_spent],
                                 :is_private => note[:is_private])

      return ReturnObject.new(:ok, "Succesfully updated note", db_note)
    else
      return ReturnObject.new(:internal_server_error, "Failed to Update note. Errors: #{db_note.errors.inspect}", nil)
    end
  end

  def delete_note(noteId)
    if Note.find(noteId).destroy()
      return ReturnObject.new(:ok, "Successfully deleted note, id: #{noteId}", nil)
    else
      return ReturnObject.new(:internal_server_error, "Failed to delete note. id: #{noteId}", nil)
    end
  end


end
