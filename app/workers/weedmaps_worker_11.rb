# frozen_string_literal: true

class WeedMapsWorker11
  include Sidekiq::Worker

  def perform
    require "json"
    logger.info "Weedmaps Job 11 is running"
    WeedmapsScraperHelper.new("Nevada", "M-R").scrapeWeedmaps
  end
end
