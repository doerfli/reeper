#!/bin/sh
set -e

# Check if Redis is available before starting Sidekiq
REDIS_URL=${REDIS_URL:-redis://redis:6379/0}
REDIS_HOST=$(echo $REDIS_URL | sed -E 's|redis://([^:/]+).*|\1|')
REDIS_PORT=$(echo $REDIS_URL | sed -E 's|.*:([0-9]+).*|\1|')

if nc -z -w 2 ${REDIS_HOST} ${REDIS_PORT} 2>/dev/null; then
  echo "✓ Redis is available at ${REDIS_HOST}:${REDIS_PORT}, starting Sidekiq..."
  bundle exec sidekiq &
else
  echo "⚠️  Redis is not available at ${REDIS_HOST}:${REDIS_PORT}, skipping Sidekiq startup"
fi

# Start Rails server in foreground
exec bundle exec rails s -p 3000 -b '0.0.0.0'
