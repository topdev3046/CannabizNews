class ErrorFound < ApplicationMailer
    default from: "noreply@cannabiznetwork.com"
	
	def email(location, inspect, error_message, backtrace)
		@location = location
		@inspect = inspect
		@error_message = error_message
		@backtrace = backtrace
		emails = ['steve@cannabiznetwork.com']
		mail(to: emails, subject: 'There was an error on CannabizNetwork')
	end
end
