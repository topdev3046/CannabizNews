class HeadsetResetCountMonthlyWorker
  include Sidekiq::Worker

  def perform(*args)
    logger.info "HeadReset Monthly Worker is Running"
    state_string = 'washington colorado nevada'
    HeadResetCountHelper.new(state_string).monthly
  end
end