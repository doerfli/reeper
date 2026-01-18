require 'sidekiq/api'

class HealthController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    health_status = {
      status: 'ok',
      timestamp: Time.current.iso8601,
      checks: {
        database: check_database,
        redis: check_redis
      }
    }

    status_code = health_status[:checks].values.all? { |check| check[:status] == 'ok' || check[:status] == 'warning' } ? :ok : :service_unavailable

    render json: health_status, status: status_code
  end

  private

  def check_database
    start_time = Time.current
    ActiveRecord::Base.connection.active?
    ActiveRecord::Base.connection.execute('SELECT 1')
    response_time = ((Time.current - start_time) * 1000).round(2)

    {
      status: 'ok',
      message: 'Database connection is active',
      response_time_ms: response_time
    }
  rescue StandardError => e
    {
      status: 'error',
      message: e.message
    }
  end

  def check_redis
    start_time = Time.current
    redis_url = ENV.fetch('REDIS_URL', 'redis://redis:6379/0')
    redis = Redis.new(url: redis_url, timeout: 1)
    redis.ping

    # Check if Sidekiq processes are actually running
    processes = Sidekiq::ProcessSet.new
    workers_count = processes.size

    response_time = ((Time.current - start_time) * 1000).round(2)

    if workers_count > 0
      {
        status: 'ok',
        message: "Sidekiq running with #{workers_count} process(es)",
        response_time_ms: response_time,
        workers: workers_count
      }
    else
      {
        status: 'warning',
        message: 'Redis is up but no Sidekiq workers are running',
        response_time_ms: response_time,
        workers: 0
      }
    end
  rescue Redis::CannotConnectError, Redis::TimeoutError, SocketError => e
    {
      status: 'error',
      message: "Redis unavailable: #{e.message}"
    }
  end
end
