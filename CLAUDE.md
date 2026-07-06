# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Project

Reeper is a self-hosted **recipe manager** built with Ruby on Rails 8.1 (server-rendered MVC — no SPA). Its standout feature is **AI-powered recipe extraction** from photos and URLs: images are OCR'd and parsed into structured recipes via Mistral and/or OpenAI. Auth is Auth0-only, images are stored on S3 via Active Storage, and background jobs run on Sidekiq/Redis. It targets privacy-conscious home cooks who self-host.

## Stack

- **Ruby 4.0.5** (see `.ruby-version`) / **Rails ~> 8.1**
- **PostgreSQL** (`pg`), **Redis** + **Sidekiq** (`sidekiq`, `sidekiq-cron`) for background jobs
- **Auth0** via `omniauth-auth0`; **AWS S3** via Active Storage (`aws-sdk-s3`, `ruby-vips`, `mini_magick`)
- **AI**: `ruby-openai`, `omniai` + `omniai-mistral`
- **Frontend**: Hotwired Stimulus + Trix/Action Text, Tailwind CSS 4, bundled with Webpack (JS) and PostCSS (CSS); package manager is **yarn**
- **Testing**: RSpec + FactoryBot + Capybara/Selenium

## Commands

- **Run app locally**: `bin/dev` (starts web `:3000`, css watch, webpack watch, and sidekiq via `Procfile.dev`). Requires a local Redis: `docker run --rm -p 6379:6379 redis:6`.
- **Install deps**: `bundle install` && `yarn install`
- **DB setup**: `rake db:create db:migrate`
- **Tests**: `bundle exec rspec` (single file: `bundle exec rspec spec/models/recipe_spec.rb`)
- **Build assets**: `yarn build` (Webpack JS), `yarn build:css` (PostCSS/Tailwind)
- **Security scan** (the enforced CI check): `bundle exec brakeman --no-pager -w2 --exit-on-warn`

Local secrets go in `.env.local` (dotenv). Key env vars: `OPENAI_API_KEY`, `MISTRAL_API_KEY`, `JINA_API_KEY` (optional), `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`, `S3_BUCKET_NAME`/`S3_BUCKET_REGION`, `AUTH0_*`. AI model names and prompt files are ENV-overridable (see `config/initializers/openai.rb`, `mistral.rb`).

## Architecture

Standard Rails layout under `app/`:

- **`app/controllers/`** — RESTful controllers. Authenticated ones `include Secured` (`app/controllers/concerns/secured.rb`); Auth0 user info lives in `session[:userinfo]`. Core: `recipes_controller.rb`, `ocr_controller.rb`, `url_import_controller.rb`, `tags_controller.rb`.
- **`app/services/`** — PORO service objects wrapping external APIs: `openai_service.rb`, `mistralai_service.rb`, `jina_service.rb`. Constructors validate API keys at runtime; controllers memoize them in private methods. **All external AI/HTTP logic goes here, not in controllers.**
- **`app/models/`** — thin Active Record models: `recipe.rb`, `tag.rb`, `user.rb`, `ocr_result.rb`.
- **`app/jobs/`** — Sidekiq jobs (scheduled via `config/sidekiq_cron.yml`).
- **`app/javascript/controllers/`** — Stimulus controllers (Webpack). **`app/views/`** — ERB + Kaminari pagination.
- **`config/prompts/*.txt`** — LLM system prompts, externalized from code and loaded via `File.read`.
- **`config/locales/en.yml` + `de.yml`** — i18n (English + German).

### OCR flow (the core feature)
Image upload → `OcrController#scan` (`POST /ocr/scan`) → a service runs OCR + parsing → results are stored as JSON on an `OcrResult` record (with the image attached) → only the `OcrResult.id` is passed forward via `flash` (to stay under cookie size limits) → `RecipesController#populate_from_ocr_data` pre-fills the new-recipe form. `OcrResult` is a transient staging record, cleaned up daily by `OcrresultCleanupJob`. Three selectable AI methods: `mistral_only` (default), `mistral_openai`, `openai_direct`. (OCR is entirely LLM-based — the old Tesseract pipeline was removed; do not reintroduce it.)

## Conventions

- **i18n is mandatory** — never hardcode user-facing strings. Add keys to both `config/locales/en.yml` and `de.yml` and reference via `t('...')` / `I18n.t('...')` (no default values).
- **RESTful design** — prefer standard controller actions (GET/POST/PATCH/DELETE) over custom actions where possible.
- **Auth0 only** — no local passwords; gate controllers with the `Secured` concern.
- **Tailwind** for all styling; 
- **Active Storage** for all file handling.
- **Defensive LLM JSON parsing** — strip ```` ```json ```` fences, `JSON.parse`, read `parsed['recipes'] || []`, rescue `JSON::ParserError`.
- **Tests stub all external services** (e.g. `allow(OpenaiService).to receive(:new).and_return(instance_double(...))`) and stub auth via `logged_in_using_omniauth?` + `session[:userinfo]`. Factories in `spec/factories/`, fixture image at `spec/fixtures/test_image.jpg`.

## Security

- Never commit secrets or credentials — all sensitive config goes through environment variables. If a secret is committed, treat it as an incident and rotate it.
- Rails defaults are relied on for CSRF, XSS escaping, and parameter filtering; keep them intact.

## Scope

In scope: recipe CRUD with rich text, multi-image attachments, AI recipe extraction, tags + full-text search, Auth0 auth, S3 storage, Docker deployment. Out of scope (don't build without being asked): native mobile apps, real-time collaboration, social/sharing features, meal planning, recipe scaling.

## Notes

- A legacy `test/` (Minitest) directory exists but **RSpec (`spec/`) is the active test suite**.
- Version claims in other docs may be stale — trust `.ruby-version`, `Gemfile`, and `package.json`.
