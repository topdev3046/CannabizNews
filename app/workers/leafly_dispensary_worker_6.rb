class LeaflyDispensaryWorker6
  include Sidekiq::Worker

	def perform()
		logger.info "Leafly Dispensary background job 6 is running"
		LeaflyScraperHelper.new('CO', 'G-L').scrapeLeafly
	end    
	
end #end of class