# frozen_string_literal: true

class ScraperError < ApplicationMailer
  default from: "noreply@cannabiznetwork.com"

  def email(scraper, inspect, error_message, backtrace)
    @scraper = scraper
    @error_message = error_message
    @inspect = inspect
    @backtrace = backtrace
    emails = ["steve@cannabiznetwork.com", "michael@cannabiznetwork.com"]
    mail(to: emails, subject: "There was an Error with one of the Scrapers")
  end
end
