class LeaflyDispensaryWorker7
  include Sidekiq::Worker

	def perform()
		logger.info "Leafly Dispensary background job 7 is running"
		LeaflyScraperHelper.new('CO', 'M-R').scrapeLeafly
	end    
	
end #end of class