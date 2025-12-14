class HealthController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    health_status = {
      status: 'ok',
      timestamp: Time.current.iso8601,
      checks: {
        database: check_database
      }
    }

    status_code = health_status[:checks].values.all? { |check| check[:status] == 'ok' } ? :ok : :service_unavailable

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
end
