class PotguideWorker2
	include Sidekiq::Worker

	def perform()
		require "json"
		logger.info "Potguide 2 Job is running"
		PotguideScraperHelper.new('Washington', 'G-L').scrapePotguide
	end
end