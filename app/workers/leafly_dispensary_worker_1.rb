class LeaflyDispensaryWorker1
  include Sidekiq::Worker
  sidekiq_options :queue => :dispensary, :retry => false

	def perform()
		logger.info "Leafly Dispensary background job 1 is running"
		LeaflyScraperHelper.new('WA', 'A-F').scrapeLeafly
	end    
	
end #end of class