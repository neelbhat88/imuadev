class ActivityService

  def initialize(current_user)
    @current_user = current_user
  end

  def index(params)
    conditions = Marshal.load(Marshal.dump(params))
    trackable_object = conditions[:trackable_type].where(id: conditions[:trackable_id]).first

    ret = get_activity_view(conditions.slice(:trackable_type, :trackable_id))

    return ReturnObject.new(:ok, "Activity for #{trackable_object.class.name} id #{trackable_object.id}.", ret)
  end

  # Helper methods - not to be called by controller

  def get_activity_view(params)
    conditions = Marshal.load(Marshal.dump(params))

    activityQ = Querier.new(PublicActivity::Activity).select([:owner_id, :key, :created_at, :updated_at]).where(conditions)
    conditions[:user_id] = activityQ.pluck(:owner_id)
    userQ = UserQuerier.new.select([:id, :role, :time_unit_id, :avatar, :class_of, :title, :first_name, :last_name]).where(conditions.slice(:user_id))
    userQ.set_subQueriers([activityQ])

    view = { users: userQ.view }

    return view
  end

end
