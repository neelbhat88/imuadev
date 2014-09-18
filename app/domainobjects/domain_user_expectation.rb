class DomainUserExpectation
  attr_accessor :id, :expectation_id, :user_id, :status, :comment, :modified_by_id, :modified_by_name,
                :title, :description, :rank

  def initialize(opts)
    user_expectation = opts[:user_expectation]
    expectation = opts[:expectation]

    if !user_expectation.nil?
      @id = user_expectation.id
      @expectation_id = user_expectation.expectation_id
      @user_id = user_expectation.user_id
      @status = user_expectation.status
      @comment = user_expectation.comment
      @modified_by_id = user_expectation.modified_by_id
      @modified_by_name = user_expectation.modified_by_name
      @updated_at = user_expectation.updated_at
    end

    if !expectation.nil?
      @title = expectation.title
      @description = expectation.description
      @rank = expectation.rank
    end
  end
end
