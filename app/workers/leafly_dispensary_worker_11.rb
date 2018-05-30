class LeaflyDispensaryWorker11
  include Sidekiq::Worker

	def perform()
		logger.info "Leafly Dispensary background job 7 is running"
		LeaflyScraperHelper.new('NV', 'M-R').scrapeLeafly
	end    
	
end #end of class