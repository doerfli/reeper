#!/bin/sh
set -e

# Start Sidekiq in background
bundle exec sidekiq &

# Start Rails server in foreground
exec bundle exec rails s -p 3000 -b '0.0.0.0'
