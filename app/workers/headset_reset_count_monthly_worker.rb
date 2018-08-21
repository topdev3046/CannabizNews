class HeadsetResetCountMonthlyWorker
  include Sidekiq::Worker

  def perform(*args)
    logger.info "HeadReset Monthly Worker is Running"
    state_string = 'washington colorado nevada'
    HeadsetResetCountHelper.new(state_string).monthly
  end
end