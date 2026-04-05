# Active Context

## Current Focus: Import from URL Feature
**Branch**: `feature/import-from-url`
**PR**: #830 — feat: implement URL import feature for recipes
**Recent Activity**: Core URL import feature implemented; PR open for review

## Overview
The application is stable at version 3.8.0 with a full AI-powered OCR workflow (Mistral AI + OpenAI). The current focus is the URL import feature, which is functionally complete on the feature branch and has an open PR (#830).

## Recently Completed (Since Last Memory Bank Update)

### Merged to main (post memory bank update):
- ✅ **PR #759** (feature/remove-tesseract) → Tagged 3.7.0: Removed all legacy Tesseract OCR components
- ✅ **PR #761** (bugfix/search-paging) → Tagged 3.7.1: Fixed search paging using params
- ✅ **PR #779** (bugfix/docker-build): Fixed Docker login/image tags to use ghcr.io
- ✅ **PR #780** (feature/docker-build) → Tagged 3.7.4: Fixed Docker push workflow for all events
- ✅ **PR #783** (feature/trivy) → Added weekly Trivy vulnerability scan workflow
- ✅ **PR #784** (feature/security) → Commented out bundler-audit/yarn-audit CI jobs
- ✅ **PR #801** (feature/ruby-4_0_2) → Tagged 3.7.12: Upgraded to Ruby 4.0.2
- ✅ **PR #809** (feature/upload_multiple) → **Tagged 3.8.0**: Multiple image uploads with enhanced Dropzone UI
- ✅ **PR #828** (feature/trivyignore) → Added .trivyignore file

### Current WIP (on feature/import-from-url, not yet merged — PR #830):
- ✅ Added omniai and omniai-mistral gems to Gemfile
- ✅ Updated Ruby to 4.0.9 in Gemfile.lock
- ✅ Updated JS dependencies (yarn.lock)
- ✅ **UrlImportController** (`app/controllers/url_import_controller.rb`): handles URL validation, Jina fetch, OpenAI parse, OcrResult creation, redirect to select or new recipe
- ✅ **JinaService** (`app/services/jina_service.rb`): fetches markdown from URL via Jina.ai reader API (`https://r.jina.ai/<url>`), supports optional `JINA_API_KEY` env var
- ✅ **OpenAI prompt** (`config/prompts/openai_url.txt`): extracts recipes from Jina markdown; preserves language; returns JSON `{recipes: [...]}` with title, ingredients, steps, prep_time, tags, source
- ✅ **`openai_service.rb`**: updated with `parse_url_to_recipes` method
- ✅ **Routes**: new `url_import` resource with `POST /url_import`; recipes namespace has `new_url` route
- ✅ **View** (`app/views/recipes/new_url.html.erb`): form to enter recipe URL
- ✅ **Navigation**: link to "Import from URL" added to `_navigation.html.erb`
- ✅ **i18n**: keys added to `en.yml` and `de.yml` for `url_import.*`
- ✅ `ai_method` tracked as `'jina_openai'` in OcrResult

## Current State
- On branch `feature/import-from-url` (3 commits ahead of main)
- Latest release: **3.8.0** (multiple image uploads)
- Ruby: **4.0.2** (.ruby-version + Gemfile.lock)
- Bundler: **4.0.9** (Gemfile.lock — note: this is the Bundler version, NOT Ruby)
- Rails: **8.1.x**
- AI OCR: AI-only workflow (Mistral + OpenAI via OmniAI gem)
- Docker build: Pushes to ghcr.io

## Active Implementation

### Import Recipe from URL (FEATURE COMPLETE — PR #830 open)
- **Flow**: User enters URL → JinaService fetches markdown → OpenAI extracts recipes → OcrResult stored → redirect to select or new recipe
- **JinaService**: uses `https://r.jina.ai/<url>`, `Accept: text/plain`, optional Bearer token
- **ai_method**: `'jina_openai'`
- **Env vars needed**: `JINA_API_KEY` (optional), `OPENAI_API_KEY`
- **Files changed vs main**: `.env`, `.env.example`, `README.md`, `custom.css`, `recipes_controller.rb`, `url_import_controller.rb`, `jina_service.rb`, `openai_service.rb`, `new_url.html.erb`, `_navigation.html.erb`, `openai.rb`, `de.yml`, `en.yml`, `openai_url.txt`, `routes.rb`

## Active Dependencies
- OpenAI API (structured recipe extraction + URL import)
- Mistral AI OCR (via OmniAI gem: omniai + omniai-mistral)
- Jina.ai reader API (URL → markdown conversion)
- OcrResult model with `ai_method` tracking
- Ruby 4.0.2 / Bundler 4.0.9 / Rails 8.1.x
- Auth0 for authentication
- AWS S3 for file storage
- Trivy for vulnerability scanning (weekly CI)

## Next Steps
1. 🔍 Review and merge PR #830
2. 📦 Tag new release post-merge (3.9.0?)
3. 🧪 Confirm `.ruby-version` matches Ruby version in Gemfile.lock (both 4.0.2)

## Known Issues
- None (`.ruby-version` is 4.0.2; Gemfile.lock Ruby is 4.0.2; Bundler is 4.0.9 — all consistent)

## Notes
- OcrController retains: cleanup_with_gpt, scan, reparse_image, show_recipe_selection
- No manual OCR / Tesseract — all removed as of 3.7.0
- Trivy weekly scan enabled; .trivyignore added for known false positives
- Docker images pushed to ghcr.io
