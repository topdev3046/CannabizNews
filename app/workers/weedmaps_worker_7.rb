class WeedMapsWorker7
	include Sidekiq::Worker

	def perform()
		require "json"
		logger.info "Weedmaps Job 7 is running"
		WeedmapsScraperHelper.new('Colorado', 'M-R').scrapeWeedmaps
	end
end