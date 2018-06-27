class ErrorFound < ApplicationMailer
    default from: "noreply@cannabiznetwork.com"
	
	def email(inspect, error_message, backtrace)
		@inspect = inspect
		@error_message = error_message
		@backtrace = backtrace
		emails = ['steve@cannabiznetwork.com']
		mail(to: emails, subject: 'There was an error on CannabizNetwork')
	end
end
