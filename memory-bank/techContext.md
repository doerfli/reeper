# Tech Context: Reeper

## Technology Stack

- **Language:** Ruby 3.4.5
- **Framework:** Ruby on Rails 8.x
- **Database:** PostgreSQL
- **Frontend:** Rails views, Tailwind CSS
- **Authentication:** Auth0 (OmniAuth)
- **File Storage:** AWS S3 (Active Storage)
- **OCR:** Tesseract via RTesseract gem
- **AI Integration:** OpenAI GPT-4 Mini (via ruby-openai gem)
- **Containerization:** Docker, Docker Compose
- **CI/CD:** GitHub Actions

## Development Setup

- Clone repository and install dependencies with `bundle install` and `yarn install`
- Database setup: `rake db:create db:migrate`
- Restore data: `pg_restore -d reeper_development -h db -Upostgres file.dump`
- **Start development server:** `bin/dev` (starts Rails server)
- **Start asset watchers:** Run `yarn build:css --watch` and `yarn build --watch` in separate terminals for CSS and JS building
- Local file storage for development, S3 for production
- Environment variables for secrets and credentials
- **OpenAI API Key:** Required in Rails credentials for GPT cleanup feature

## Technical Constraints

- Must run on Ruby 3.4.5+
- Rails 8.x required
- PostgreSQL required (no SQLite support)
- S3 required for production file storage
- Auth0 required for authentication
- OpenAI API key required for GPT cleanup functionality
- Docker required for deployment

## Dependencies

- Rails, pg, puma, cssbundling-rails, jsbundling-rails, uglifier, coffee-rails, turbolinks, jbuilder, ffi, mini_magick, aws-sdk-s3, kaminari, rtesseract, image_processing
- **AI:** ruby-openai (~> 7.0)
- Dev dependencies: bootsnap, rspec-rails, rubocop, etc.

## Environment Variables

- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `S3_BUCKET_NAME`, `S3_BUCKET_REGION`
- `AUTH0_CLIENT_ID`, `AUTH0_CLIENT_SECRET`, `AUTH0_DOMAIN`, `AUTH0_DB_CONNECTION`
- **OpenAI:** `openai_api_key` (stored in Rails credentials, not environment variables)

## Deployment

- Production: `docker-compose.prod.yml`
- Development: `docker-compose.yml`, `bin/dev`
- Backups: `pg_dump`, `pg_restore`

## Known Issues

- Ruby version upgrades require Docker and workflow updates
- S3 credentials must be managed securely
- Auth0 configuration must be kept up to date
- OpenAI API usage should be monitored for cost control

- Ruby version upgrades require Docker and workflow updates
- S3 credentials must be managed securely
- Auth0 configuration must be kept up to date
