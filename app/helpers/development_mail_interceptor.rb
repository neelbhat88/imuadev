class DevelopmentMailInterceptor
	def self.delivering_email(message)
		Rails.logger.debug("******** Recipients: #{message.to}")

		final_emails = []
		message.to.each do |email|
			user = User.find_by_email(email)

			final_emails.append(user.email) if user.status != Constants.UserStatus[:GHOST]
		end

		if final_emails.empty?
			message.perform_deliveries = false
			return
		end

		message.subject = "#{final_emails} #{message.subject}"
		message.to = ENV['DEV_EMAIL']
	end
end
