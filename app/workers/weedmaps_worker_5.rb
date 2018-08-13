# frozen_string_literal: true

class WeedMapsWorker5
  include Sidekiq::Worker

  def perform
    require "json"
    logger.info "Weedmaps Job 5 is running"
    WeedmapsScraperHelper.new("Colorado", "A-F").scrapeWeedmaps
  end
end
