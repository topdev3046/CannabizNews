# frozen_string_literal: true

class WeedMapsWorker6
  include Sidekiq::Worker

  def perform
    require "json"
    logger.info "Weedmaps 6 Job is running"
    WeedmapsScraperHelper.new("Colorado", "G-L").scrapeWeedmaps
  end
end
