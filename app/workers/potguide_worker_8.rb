# frozen_string_literal: true

class PotguideWorker8
  include Sidekiq::Worker

  def perform
    require "json"
    logger.info "Potguide Job 8 is running"
    PotguideScraperHelper.new("Colorado", "S-Z").scrapePotguide
  end
end
