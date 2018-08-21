# frozen_string_literal: true

class TheCannabistWorker
  include Sidekiq::Worker

  def perform
    logger.info "The Cannabist background job is running"
    scrapeCannabist()
    end

  def scrapeCannabist
    require "json"
    require "open-uri"

    begin
    output = IO.popen(["python", "#{Rails.root}/app/scrapers/newsparser_thecannabist.py"]) # cmd,
    contents = JSON.parse(output.read)

    # call method
    if contents["articles"].present?
      NewsScraperHelper.new(contents["articles"], "The Cannabist").addArticles
    else
      ScraperError.email("TheCannabist News", "No Articles were returned", "", "").deliver
    end
   rescue => ex
     ScraperError.email("TheCannabist News", ex.inspect, ex.message, ex.backtrace.join("\n")).deliver_now
  end
  end
end
