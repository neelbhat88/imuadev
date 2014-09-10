class DomainUserGpa
  attr_accessor :core_unweighted, :core_weighted, :regular_unweighted,
                :regular_weighted, :time_unit_id, :user_id

  def initialize(user_gpa)
    @core_unweighted = user_gpa.core_unweighted
    @core_weighted = user_gpa.core_weighted
    @regular_unweighted = user_gpa.regular_unweighted
    @regular_weighted = user_gpa.regular_weighted
    @time_unit_id = user_gpa.time_unit_id
    @user_id = user_gpa.user_id
  end

end
