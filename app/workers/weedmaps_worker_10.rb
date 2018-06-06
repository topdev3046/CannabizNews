class WeedMapsWorker10
	include Sidekiq::Worker

	def perform()
		require "json"
		logger.info "Weedmaps 10 Job is running"
		WeedmapsScraperHelper.new('Nevada', 'G-L').scrapeWeedmaps
	end
end