class LeaflyDispensaryWorker2
  include Sidekiq::Worker

	def perform()
		logger.info "Leafly Dispensary background job CO is running"
		LeaflyScraperHelper.new('CO').scrapeLeafly
	end    
	
end #end of class