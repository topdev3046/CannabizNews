class LeaflyDispensaryWorker8
  include Sidekiq::Worker

	def perform()
		logger.info "Leafly Dispensary background job 8 is running"
		LeaflyScraperHelper.new('CO', 'S-Z').scrapeLeafly
	end    
	
end #end of class