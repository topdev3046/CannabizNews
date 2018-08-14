# frozen_string_literal: true

class PotguideWorker3
  include Sidekiq::Worker

  def perform
    require "json"
    logger.info "Potguide Job 3 is running"
    PotguideScraperHelper.new("Washington", "M-R").scrapePotguide
  end
end
