class WeedMapsWorker2
	include Sidekiq::Worker

	def perform()
		require "json"
		logger.info "Weedmaps 2 Job is running"
		WeedmapsScraperHelper.new('Washington', 'G-L').scrapeWeedmaps
	end
end