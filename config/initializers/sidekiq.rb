Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://redis:6379/0') }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://redis:6379/0') }
end

# Load cron jobs
if Sidekiq.server?
  schedule_file = "config/sidekiq_cron.yml"
  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash(YAML.load_file(schedule_file))
    Rails.logger.info "Sidekiq cron jobs loaded from #{schedule_file}"
  end
end
