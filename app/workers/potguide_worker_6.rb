# frozen_string_literal: true

class PotguideWorker6
  include Sidekiq::Worker

  def perform
    require "json"
    logger.info "Potguide 6 Job is running"
    PotguideScraperHelper.new("Colorado", "G-L").scrapePotguide
  end
end
