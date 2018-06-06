class WeedMapsWorker9
	include Sidekiq::Worker

	def perform()
		require "json"
		logger.info "Weedmaps Job 9 is running"
		WeedmapsScraperHelper.new('Nevada', 'A-F').scrapeWeedmaps
	end
end