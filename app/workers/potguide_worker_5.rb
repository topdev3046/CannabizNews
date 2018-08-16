# frozen_string_literal: true

class PotguideWorker5
  include Sidekiq::Worker

  def perform
    require "json"
    logger.info "Potguide Job 5 is running"
    PotguideScraperHelper.new("Colorado", "A-F").scrapePotguide
  end
end
