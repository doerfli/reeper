begin
  redis_config = { url: ENV.fetch('REDIS_URL', 'redis://redis:6379/0'), timeout: 1 }

  # Test Redis connection
  Redis.new(redis_config).ping

  Sidekiq.configure_server do |config|
    config.redis = redis_config
  end

  Sidekiq.configure_client do |config|
    config.redis = redis_config
  end

  # Load cron jobs
  if Sidekiq.server?
    schedule_file = "config/sidekiq_cron.yml"
    if File.exist?(schedule_file)
      Sidekiq::Cron::Job.load_from_hash(YAML.load_file(schedule_file))
      Rails.logger.info "Sidekiq cron jobs loaded from #{schedule_file}"
    end
  end

  Rails.logger.info "Sidekiq configured successfully with Redis at #{redis_config[:url]}"
rescue Redis::CannotConnectError, Redis::TimeoutError, SocketError => e
  Rails.logger.warn "⚠️  Redis is not available: #{e.message}. Sidekiq will not be functional."
  # Don't raise the error, just log it
end
