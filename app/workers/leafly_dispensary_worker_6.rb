class LeaflyDispensaryWorker4
  include Sidekiq::Worker

	def perform()
		logger.info "Leafly Dispensary background job 4 is running"
		LeaflyScraperHelper.new('CO', 'G-L').scrapeLeafly
	end    
	
end #end of class