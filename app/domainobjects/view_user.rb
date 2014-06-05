class ViewUser
	attr_accessor :id, :email, :first_name, :last_name,
								:phone, :role, :avatar_url,
								:is_super_admin, :is_org_admin

	def initialize(user)
		@id = user.id
		@email = user.email
		@first_name = user.first_name
		@last_name = user.last_name
		@phone = user.phone
		@role = user.role
		@square_avatar_url = user.avatar.url(:square)

		@is_super_admin = user.super_admin?
		@is_org_admin = user.org_admin?
	end
end