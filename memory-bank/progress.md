# Progress: Reeper

## What Works

- Recipe CRUD (create, read, update, delete)
- Image attachments and AI-powered recipe extraction
- **Two-phase AI recognition:** Mistral AI (image → markdown) + OpenAI (markdown → structured recipe)
- **Multiple image uploads:** Dropzone supports uploading multiple images at once with preview
- **Multiple AI services:** Mistral AI for OCR (via OmniAI gem), OpenAI for structured extraction
- **OCR with AI cleanup:** OCR results can be cleaned up using GPT-4 Mini for better accuracy
- **Language-aware AI processing:** GPT cleanup adapts to German/English with recipe-specific prompts
- **Multiple recipes support:** Detect and select from multiple recipes in a single image
- Tagging and search/filtering
- Auth0 authentication
- AWS S3 file storage
- Dockerized development and production environments (images pushed to ghcr.io)
- Responsive UI with Tailwind CSS
- Database backup/restore
- Trivy weekly vulnerability scan (CI)

## What's Left to Build

- **Import recipe from URL** (in progress — feature/import-from-url branch)
- Improved mobile experience
- Plugin/extension architecture
- Advanced search (ingredient-based, fuzzy)
- Recipe scaling/conversion tools
- Community features (optional, future)

## Current Status

- Project is stable and in active development
- All core features are implemented and working
- Multiple image uploads shipped in 3.8.0 (April 2026)
- AI-only OCR workflow (Tesseract fully removed since 3.7.0)
- Ruby: **4.0.2** (.ruby-version), Gemfile.lock updated to 4.0.9 (in progress)
- Rails: **8.1.x**
- No critical bugs open
- Latest release: **Tag 3.8.0** (April 2026)

## Recent Completions

### Multiple Image Upload (3.8.0) ✅ (April 2026)
- **PR:** #809 (feature/upload_multiple)
- **Components:**
  - Enhanced Dropzone with multiple image preview support
  - Disabled upload button during preview mode (improved UX)
  - Replaced AI method selection dropdown with details/summary element
- **Status:** Merged and released as 3.8.0

### Trivy Vulnerability Scanning ✅ (March 2026)
- **PR:** #783 (feature/trivy), #828 (feature/trivyignore)
- Weekly Trivy scan CI workflow added
- .trivyignore file for known false positives

### Docker Build Fixes ✅ (February 2026)
- **PR #779** (bugfix/docker-build): Fixed Docker login and image tags to use ghcr.io
- **PR #780** (feature/docker-build, 3.7.4): Enabled pushing images for all events

### Ruby 4.0.2 Upgrade ✅ (February 2026)
- **PR:** #801 (feature/ruby-4_0_2), tagged 3.7.12
- Updated Ruby from 3.x to 4.0.2

### Legacy Tesseract OCR Removal ✅ (January 2026)
- **PR:** #759 (feature/remove-tesseract), tagged 3.7.0
- Removed all Tesseract OCR components, manual region selection UI, and orphaned JS controllers
- Application now uses AI-only OCR workflow

### OCR Result Cleanup Job ✅ (January 2026)
- **PR:** #753 (feature/ocrresult-cleanup)
- OcrresultCleanupJob cleans up OCR results older than 1 day
- Sidekiq cron scheduled for automated cleanup

### Two-Phase AI Recognition ✅ (January 2026)
- **PR:** #752 (feature/mistral-ai-ocr)
- Mistral AI OCR for markdown extraction + OpenAI for structured recipe parsing
- AI method tracking in OcrResult model
- User choice between "Mistral + OpenAI" or "OpenAI Direct"

### Multiple Recipes Support ✅ (December 2025)
- **PR:** #734, tagged 3.3.0
- Multi-recipe detection, recipe selection UI, flash-based state management

### GPT OCR Cleanup Feature ✅ (September 2025)
- Language-aware OCR cleanup with GPT-4 Mini
- German/English recipe-specific prompts

# Progress Tracking

## Current Sprint (April 2026)

### In Progress
- 🔄 Import recipe from URL (branch: feature/import-from-url)
  - Foundation: omniai + omniai-mistral gems added
  - Ruby 4.0.9 Gemfile.lock update in progress
  - Feature implementation not yet started

### Recently Completed
- ✅ PR #809: Multiple image uploads (3.8.0)
- ✅ PR #828: .trivyignore file
- ✅ PR #801: Ruby 4.0.2 upgrade (3.7.12)
- ✅ PR #783/784: Trivy + security workflow updates
- ✅ PR #779/780: Docker build fixes (3.7.4)
- ✅ PR #761: Search paging bugfix (3.7.1)
- ✅ PR #759: Tesseract OCR removal (3.7.0)
- ✅ PR #753: OCR result cleanup job
- ✅ PR #752: Two-phase AI recognition
- ✅ PR #734: Multiple recipes support (3.3.0)
- ✅ Basic AI OCR recipe extraction (magic recipe feature)

## Upcoming Tasks
1. Test two-phase AI recognition with diverse recipe images
2. Compare accuracy and performance between AI methods
3. Merge feature/mistral-ai-ocr to main
4. Monitor production performance of both AI methods
5. Address test suite dependency issues (chromedriver-helper)
6. Add comprehensive tests for OCR controller
7. Consider adding analytics/feedback for AI method comparison
8. Plan and scope next feature development

## Blockers
- **Test Suite Issue**: chromedriver-helper gem incompatible with Ruby 4.0.2
  - Prevents running full test suite
  - May need to migrate to selenium-webdriver without helper gem
  - Not blocking feature development but needs resolution soon

## Technical Debt

### High Priority
1. **Empty OCR Controller Tests**: `spec/controllers/ocr_controller_spec.rb` has no tests
2. **Weak Error Handling**: `rescue []` in OpenAI service silently fails
3. **Missing Bounds Validation**: No check if `recipe_index` exceeds array length
4. **Test Suite Dependency**: chromedriver-helper needs replacement

### Medium Priority
1. **Debug Console.log Statements**: Several active console.log in JavaScript controllers
2. **Hardcoded Prompt IDs**: OpenAI prompt configuration could be more flexible
3. **Filename Extension Bug**: Line 168 in ocr_controller.rb uses `blob.filename.to_json` instead of `blob.filename.to_s`

### Low Priority
1. **Code Documentation**: Add more inline comments for complex OCR logic
2. **Performance Monitoring**: Add metrics for OpenAI API response times
3. **User Analytics**: Track multi-recipe selection patterns

## Notes
- Focus: Stable state, monitoring production performance
- Multiple recipes feature is backward compatible with single-recipe workflow
- All GitHub Actions CI/CD checks passing successfully
- Latest release: 3.3.0 (December 21, 2025)
- Ready for next feature development cycle

## Known Issues

- Ruby upgrades require coordinated changes in Docker, workflows, and documentation
- S3 and Auth0 credentials must be managed securely
- OpenAI API usage should be monitored for cost control
- Occasional dependency update breakages (monitored via CI)
