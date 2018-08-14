# frozen_string_literal: true

class WeedMapsWorker8
  include Sidekiq::Worker

  def perform
    require "json"
    logger.info "Weedmaps Job 8 is running"
    WeedmapsScraperHelper.new("Colorado", "S-Z").scrapeWeedmaps
  end
end
