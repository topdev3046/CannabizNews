# frozen_string_literal: true

class DispPotguide < ActiveJob::Base
  include SuckerPunch::Job

  def perform(state_name, city_range)
    @state_name = state_name
    @city_range = city_range
    logger.info "Potguide Job is running"
    PotguideScraperHelper.new(@state_name, @city_range).scrapePotguide
end
end # end of class
