class WeedMapsWorker4
	include Sidekiq::Worker

	def perform()
		require "json"
		logger.info "Weedmaps Job 4 is running"
		WeedmapsScraperHelper.new('Washington', 'S-Z').scrapeWeedmaps
	end
end