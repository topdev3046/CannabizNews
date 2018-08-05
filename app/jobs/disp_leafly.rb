class DispLeafly < ActiveJob::Base
    include SuckerPunch::Job

	def perform(state_abbreviation)
		logger.info "Leafly Dispensary background job is running"
		@state_abbreviation = state_abbreviation
		LeaflyScraperHelper.new(@state_abbreviation).scrapeLeafly
	end
	
end #end of class
