class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.student?
      can :view, UserExpectation
    elsif user.mentor?
      can :manage, UserExpectation
      cannot :destroy, UserExpectation
    end

  end
end
