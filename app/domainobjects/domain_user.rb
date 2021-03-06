class DomainUser

	def initialize(user, options = {})

		unless user.nil?
			@id = user.id
			@email = user.email
			@first_name = user.first_name
			@last_name = user.last_name
			@full_name = user.full_name
			@first_last_initial = user.first_last_initial
			@title = user.title
			@phone = user.phone
			@role = user.role
			@organization_id = user.organization_id
			@square_avatar_url = user.avatar.url(:square)
			@time_unit_id = user.time_unit_id
			@class_of = user.class_of.to_i
			@login_count = user.sign_in_count
			@last_login = user.current_sign_in_at ? user.current_sign_in_at : "Has not logged in yet"

			@is_student = user.student?
			@is_mentor = user.mentor?
			@is_org_admin = user.org_admin?
			@is_super_admin = user.super_admin?
		end

		@organization_name = options[:organization].name unless options[:organization].nil?

		@relationships = options[:relationships] unless options[:relationships].nil?

		@user_expectations = options[:user_expectations] unless options[:user_expectations].nil?
		@user_milestones = options[:user_milestones] unless options[:user_milestones].nil?
		@user_classes = options[:user_classes] unless options[:user_classes].nil?
		@user_service_hours = options[:user_service_hours] unless options[:user_service_hours].nil?
		@user_extracurricular_activity_details = options[:user_extracurricular_activity_details] unless options[:user_extracurricular_activity_details].nil?
		@user_tests = options[:user_tests] unless options[:user_tests].nil?

		@assignments = options[:assignments] unless options[:assignments].nil?
		@user_assignments = options[:user_assignments] unless options[:user_assignments].nil?
	end

end
