class LeaflyDispensaryWorker10
  include Sidekiq::Worker

	def perform()
		logger.info "Leafly Dispensary background job 6 is running"
		LeaflyScraperHelper.new('NV', 'G-L').scrapeLeafly
	end    
	
end #end of class