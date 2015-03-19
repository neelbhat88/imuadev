class Session <  ActiveRecord::SessionStore::Session

  def self.find_by_session_id(session_id)
    find(:first,:conditions => ["session_id = ?",session_id])
  end

end
