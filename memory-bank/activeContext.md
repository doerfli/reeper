# Active Context

## Current Focus: Import from URL Feature
**Branch**: `feature/import-from-url`
**Recent Activity**: Set up dependencies for URL-based recipe import feature; added omniai and omniai-mistral gems

## Overview
The application is now stable at version 3.8.0 with a full AI-powered OCR workflow (Mistral AI + OpenAI). The current focus is building recipe import from URL functionality. Recent foundational work includes adding omniai/omniai-mistral gems and updating Ruby to 4.0.9 in Gemfile.lock.

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

### Current WIP (on feature/import-from-url, not yet released):
- ✅ Added omniai and omniai-mistral gems to Gemfile
- ✅ Updated Ruby to 4.0.9 in Gemfile.lock
- ✅ Updated JS dependencies (yarn.lock)
- 🔄 Import recipe from URL feature (in progress)

## Current State
- On `main` branch (HEAD also tracked as `feature/import-from-url`)
- Latest release: **3.8.0** (multiple image uploads)
- Ruby: **4.0.2** (.ruby-version), **4.0.9** (Gemfile.lock — update in progress)
- Rails: **8.1.x**
- AI OCR: AI-only workflow (Mistral + OpenAI via OmniAI gem)
- Docker build: Pushes to ghcr.io

## Active Implementation

### Multiple Image Upload (3.8.0 — MERGED)
- Enhanced Dropzone component with multiple image preview
- Disabled upload button during preview mode
- Replaced AI method dropdown with details/summary UI element

### Import Recipe from URL (IN PROGRESS)
- Foundation: omniai + omniai-mistral gems added
- Feature: Allow users to import recipes by providing a URL
- Status: Early stage, implementation not yet committed

## Active Dependencies
- OpenAI API (structured recipe extraction)
- Mistral AI OCR (via OmniAI gem: omniai + omniai-mistral)
- OcrResult model with `ai_method` tracking
- Ruby 4.0.2 / Rails 8.1.x
- Auth0 for authentication
- AWS S3 for file storage
- Trivy for vulnerability scanning (weekly CI)

## Next Steps
1. 🔄 Implement URL import feature on `feature/import-from-url` branch
2. 🧪 Test import workflow end-to-end
3. 🚀 Open PR and merge when ready
4. 📦 Tag new release post-merge

## Known Issues
- `.ruby-version` still says 4.0.2 but Gemfile.lock was updated to 4.0.9 (inconsistency to resolve)

## Notes
- OcrController retains: cleanup_with_gpt, scan, reparse_image, show_recipe_selection
- No manual OCR / Tesseract — all removed as of 3.7.0
- Trivy weekly scan enabled; .trivyignore added for known false positives
- Docker images pushed to ghcr.io
