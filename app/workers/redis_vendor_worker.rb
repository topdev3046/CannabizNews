# frozen_string_literal: true

class RedisVendorWorker
  include Sidekiq::Worker

  def perform
    logger.info "Redis Vendor Worker is Running"
    setVendorKeys()
  end

  def setVendorKeys
    RedisSetVendorKeys.set_vendor_keys()
  end
end
