class LeaflyDispensaryWorker9
  include Sidekiq::Worker

	def perform()
		logger.info "Leafly Dispensary background job 5 is running"
		LeaflyScraperHelper.new('NV', 'A-F').scrapeLeafly
	end    
	
end #end of class