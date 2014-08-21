class ViewUser
	attr_accessor :id, :email, :first_name, :last_name, :full_name, :first_last_initial,
								:phone, :role, :avatar_url,
								:organization_id, :time_unit_id, :class_of,
								:modules_progress, :user_milestones, :relationships

	def initialize(user)
		@id = user.id
		@email = user.email
		@first_name = user.first_name
		@last_name = user.last_name
		@full_name = user.full_name
		@first_last_initial = user.first_last_initial
		@phone = user.phone
		@role = user.role
		@organization_id = user.organization_id
		@square_avatar_url = user.avatar.url(:square)
		@time_unit_id = user.time_unit_id
		@class_of = user.class_of.to_i

		@is_student = user.student?
		@is_mentor = user.mentor?
		@is_org_admin = user.org_admin?
		@is_super_admin = user.super_admin?

		@modules_progress = []
		@user_milestones = user.user_milestones
		@relationships = user.relationships
	end
end
