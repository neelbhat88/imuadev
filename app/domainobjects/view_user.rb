class ViewUser
	attr_accessor :id, :email, :first_name, :last_name, :full_name, :first_last_initial,
								:phone, :role, :avatar_url,
								:organization_id, :time_unit_id, :class_of,
								:modules_progress, :user_milestones, :relationships,
								:login_count, :last_login

	def initialize(user, org = nil)
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
		@login_count = user.sign_in_count
		@last_login = user.current_sign_in_at ? user.current_sign_in_at.strftime("%m/%d/%Y") : "Has not logged in yet"

		@is_student = user.student?
		@is_mentor = user.mentor?
		@is_org_admin = user.org_admin?
		@is_super_admin = user.super_admin?

		@modules_progress = []

		@organization_name = org.name unless org.nil?

		if user.student?
			@relationships = user.relationships

			@user_expectations = user.user_expectations
			@user_milestones = user.user_milestones

			@user_classes = user.user_classes
			@user_extracurricular_activity_details = user.user_extracurricular_activity_details
			@user_service_hours = user.user_service_hours
			@user_tests = user.user_tests
		end

		if user.mentor?
			@relationships = user.relationships
		end

	end
end
