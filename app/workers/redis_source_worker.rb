class RedisSourceWorker
    include Sidekiq::Worker
    
    def perform()
        logger.info "Redis Source Worker is Running"
        setSourceKeys()
    end    
    
    def setSourceKeys()
        RedisSetSourceKeys.set_source_keys()
    end  
end