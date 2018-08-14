# frozen_string_literal: true

class LeaflyDispensaryWorker3
  include Sidekiq::Worker

  def perform
    logger.info "Leafly Dispensary background job NV is running"
    LeaflyScraperHelper.new("NV").scrapeLeafly
  end
end # end of class
