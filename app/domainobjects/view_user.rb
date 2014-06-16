class ViewUser
	attr_accessor :id, :email, :first_name, :last_name,
								:phone, :role, :avatar_url,
								:organization_id, :time_unit_id

	def initialize(user)
		@id = user.id
		@email = user.email
		@first_name = user.first_name
		@last_name = user.last_name
		@phone = user.phone
		@role = user.role
		@organization_id = user.organization_id
		@square_avatar_url = user.avatar.url(:square)
		@time_unit_id = user.time_unit_id
	end
end