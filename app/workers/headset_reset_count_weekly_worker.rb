class HeadsetResetCountWeeklyWorker
  include Sidekiq::Worker

  def perform(*args)
    logger.info "HeadReset Weekly Worker is Running"
    state_string = 'washington colorado nevada'
    HeadsetResetCountHelper.new(state_string).weekly
  end
end