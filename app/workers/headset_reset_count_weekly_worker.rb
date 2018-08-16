class HeadsetResetCountWeeklyWorker
  include Sidekiq::Worker

  def perform(*args)
    logger.info "HeadReset Weekly Worker is Running"
    state_string = 'washington colorado nevada'
    HeadResetCountHelper.new(state_string).weekly
  end
end