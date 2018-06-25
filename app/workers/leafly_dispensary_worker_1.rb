class LeaflyDispensaryWorker1
  include Sidekiq::Worker
  sidekiq_options :queue => :dispensary, :retry => false

	def perform()
		logger.info "Leafly Dispensary background WA Job"
		LeaflyScraperHelper.new('WA').scrapeLeafly
	end    
	
end #end of class