class LeaflyDispensaryWorker5
  include Sidekiq::Worker

	def perform()
		logger.info "Leafly Dispensary background job 5 is running"
		LeaflyScraperHelper.new('CO', 'A-F').scrapeLeafly
	end    
	
end #end of class