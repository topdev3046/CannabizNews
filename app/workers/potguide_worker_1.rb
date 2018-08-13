# frozen_string_literal: true

class PotguideWorker1
  include Sidekiq::Worker

  def perform
    require "json"
    logger.info "Potguide Job 1 is running"
    PotguideScraperHelper.new("Washington", "A-F").scrapePotguide
  end
end
