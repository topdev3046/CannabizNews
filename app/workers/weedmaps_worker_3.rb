# frozen_string_literal: true

class WeedMapsWorker3
  include Sidekiq::Worker

  def perform
    require "json"
    logger.info "Weedmaps Job 3 is running"
    WeedmapsScraperHelper.new("Washington", "M-R").scrapeWeedmaps
  end
end
