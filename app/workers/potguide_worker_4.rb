class PotguideWorker4
	include Sidekiq::Worker

	def perform()
		require "json"
		logger.info "Potguide Job 4 is running"
		PotguideScraperHelper.new('Washington', 'S-Z').scrapePotguide
	end
end