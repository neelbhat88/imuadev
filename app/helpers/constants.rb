class Constants
	def self.UserRole
		return { 
			SUPER_ADMIN: 0,
			ORG_ADMIN: 10,
			SCHOOL_ADMIN: 20,
			COHORT_LEAD: 30,
			MENTOR: 40,
			STUDENT: 50,
			PARENT: 60
		}
	end
end