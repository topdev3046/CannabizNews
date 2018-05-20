class LeaflyDispensaryWorker3
  include Sidekiq::Worker

	def perform()
		logger.info "Leafly Dispensary background job 3 is running"
		LeaflyScraperHelper.new('WA', 'M-R').scrapeLeafly
	end    
	
end #end of class