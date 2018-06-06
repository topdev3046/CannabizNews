class WeedMapsWorker12
	include Sidekiq::Worker

	def perform()
		require "json"
		logger.info "Weedmaps Job 12 is running"
		WeedmapsScraperHelper.new('Nevada', 'S-Z').scrapeWeedmaps
	end
end