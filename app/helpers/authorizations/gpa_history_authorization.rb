class GpaHistoryAuthorization
  attr_reader :user_ids
  
  def initialize(user_ids)
    @user_ids = user_ids
  end

end
