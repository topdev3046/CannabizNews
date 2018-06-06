class WeedMapsWorker1
	include Sidekiq::Worker

	def perform()
		require "json"
		logger.info "Weedmaps Job 1 is running"
		WeedmapsScraperHelper.new('Washington', 'A-F').scrapeWeedmaps
	end
end