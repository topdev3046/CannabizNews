# frozen_string_literal: true

class PotguideWorker7
  include Sidekiq::Worker

  def perform
    require "json"
    logger.info "Potguide Job 7 is running"
    PotguideScraperHelper.new("Colorado", "M-R").scrapePotguide
  end
end
