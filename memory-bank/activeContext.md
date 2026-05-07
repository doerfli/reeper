# Active Context

## Current Focus: Mistral-Only AI Method + Configurable Model/Prompt
**Branch**: `feature/use-mistral-model`
**PR**: #850 — use Mistral for markdown parsing
**Recent Activity**: Added `mistral_only` as new default AI method, fixed `mistral_openai` bug, made Mistral model/prompt configurable

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
- ✅ **PR #830** (feature/import-from-url): URL import feature (Jina.ai + OpenAI, `ai_method: 'jina_openai'`)

### Current WIP (on feature/use-mistral-model, not yet merged — PR #850):
- ✅ Bundler updated from 4.0.9 → 4.0.11 (Gemfile.lock)
- ✅ **New `mistral_only` AI method**: Mistral OCR → Mistral parsing (new default in UI and controller)
- ✅ **Fixed `mistral_openai`**: now correctly routes to Mistral OCR → OpenAI parsing (was accidentally using Mistral parser in both phases)
- ✅ **`config/initializers/mistral.rb`**: configures `Rails.configuration.mistral.markdown_model` (default: `mistral-small-latest`, override via `MISTRAL_MARKDOWN_MODEL`) and `markdown_prompt_file` (default: `mistral_markdown.txt`, override via `MISTRAL_MARKDOWN_PROMPT_FILE`)
- ✅ **`config/prompts/mistral_markdown.txt`**: duplicate of `openai_markdown.txt` for Mistral-specific tuning
- ✅ **`mistralai_service.rb`**: `parse_markdown_to_recipes` now reads model/prompt from `Rails.configuration.mistral.*`
- ✅ **`ocr_controller.rb`**: both `scan` and `reparse_image` actions have 3-way branch (`mistral_only` / `mistral_openai` / else), default fallback → `'mistral_only'`
- ✅ **Views** (`new_magic.html.erb`, `select_image_for_reparse.html.erb`): `mistral_only` added as first/default option; all three methods shown
- ✅ **i18n**: `mistral_only` key added to `en.yml` ('Mistral Only') and `de.yml` ('Mistral')

## Current State
- On branch `feature/use-mistral-model` (PR #850 open)
- Latest release: **3.8.0** (multiple image uploads)
- Ruby: **4.0.2** (.ruby-version + Gemfile.lock)
- Bundler: **4.0.11** (Gemfile.lock — note: this is the Bundler version, NOT Ruby)
- Rails: **8.1.x**
- AI OCR: AI-only workflow (Mistral + OpenAI via OmniAI gem)
- Docker build: Pushes to ghcr.io

## Active Implementation

### Mistral-Only AI Method + Configurable Model/Prompt (PR #850 open)
- **AI method values**: `mistral_only` (default), `mistral_openai`, `openai_direct`
- **`mistral_only`**: Mistral OCR → `mistral_service.parse_markdown_to_recipes`
- **`mistral_openai`**: Mistral OCR → `openai_service.parse_markdown_to_recipes`
- **`openai_direct`**: `openai_service.ocr` (single-phase)
- **Configurable via ENV**: `MISTRAL_MARKDOWN_MODEL`, `MISTRAL_MARKDOWN_PROMPT_FILE`
- **Prompt files**: `config/prompts/mistral_markdown.txt` (Mistral), `config/prompts/openai_markdown.txt` (OpenAI)
- **Files changed vs main**: `config/initializers/mistral.rb` (new), `config/prompts/mistral_markdown.txt` (new), `mistralai_service.rb`, `ocr_controller.rb`, `new_magic.html.erb`, `select_image_for_reparse.html.erb`, `en.yml`, `de.yml`, `Gemfile.lock`, `.devcontainer/devcontainer-lock.json`, `config/audit/vulnerabilities.yml`

## Active Dependencies
- OpenAI API (structured recipe extraction + URL import)
- Mistral AI OCR + parsing (via OmniAI gem: omniai + omniai-mistral)
- Jina.ai reader API (URL → markdown conversion)
- OcrResult model with `ai_method` tracking
- Ruby 4.0.2 / Bundler 4.0.11 / Rails 8.1.x
- Auth0 for authentication
- AWS S3 for file storage
- Trivy for vulnerability scanning (weekly CI)

## Next Steps
1. 🔍 Review and merge PR #850
2. 📦 Tag new release post-merge (3.9.0?)

## Known Issues
- None (`.ruby-version` is 4.0.2; Gemfile.lock Ruby is 4.0.2; Bundler is 4.0.11 — all consistent)

## Notes
- OcrController retains: cleanup_with_gpt, scan, reparse_image, show_recipe_selection
- No manual OCR / Tesseract — all removed as of 3.7.0
- Trivy weekly scan enabled; .trivyignore added for known false positives
- Docker images pushed to ghcr.io
