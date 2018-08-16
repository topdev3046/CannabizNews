class HeadsetResetCountDailyWorker
  include Sidekiq::Worker

  def perform(*args)
    logger.info "HeadReset Daily Worker is Running"
    state_string = 'washington colorado nevada'
    HeadResetCountHelper.new(state_string).daily
  end
end