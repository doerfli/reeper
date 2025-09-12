# Active Context: Reeper

## Current Focus (as of September 12, 2025)

- **Image Rotation for OCR:** NEW - Added client-side image rotation controls for better OCR accuracy without modifying stored images
- **GPT OCR Cleanup Feature:** Added AI-powered text cleanup for OCR results using GPT-4 Mini
- **Ruby Upgrade:** Project has been upgraded to Ruby 3.4.5 (see recent commits and merged PR #657)
- **OCR Enhancement:** Enhanced OCR functionality with AI cleanup and rotation - OCR results can now be cleaned up via GPT and images can be rotated for better recognition
- **Dependency Updates:** All dependencies are being kept up to date for security and compatibility
- **Docker/Devcontainer:** Devcontainer and Dockerfile updated for new Ruby version and manual install
- **Auth0 Integration:** Authentication flow stable, no recent changes
- **General Maintenance:** Ongoing bug fixes, minor enhancements, and dependency bumps

## Recent Changes

- **NEW FEATURE:** Added image rotation controls for OCR processing
  - Client-side rotation using CSS transforms and Stimulus
  - Session-only persistence (resets on page reload)
  - Backend integration with MiniMagick for actual OCR processing
  - No modification of stored images in ActiveStorage
  - Smooth 0.3s transitions for better UX
- **EXISTING FEATURE:** Added GPT-4 Mini powered text cleanup for OCR results
  - Language-aware cleanup (German/English)
  - Recipe-specific prompts optimized for cooking content
  - Integrated into existing OCR workflow
  - Added `ruby-openai` gem dependency
  - Created `OpenaiCleanupService` service class
- Merged feature branch `feature/ruby-345` into `main`
- Updated `.ruby-version` to 3.4.5
- Updated Dockerfile, devcontainer, and GitHub Actions for Ruby 3.4.5
- Updated Gemfile.lock for new Ruby version

## Next Steps

- Test image rotation feature with various image orientations
- Test GPT cleanup feature in production
- Monitor OpenAI API usage and costs
- Continue dependency and security updates
- Review and improve documentation

## Active Decisions

- Standardize on Ruby 3.4.5 for all environments
- Use manual Ruby install in devcontainer for flexibility
- Continue using Auth0 for authentication
- **GPT Integration:** Use GPT-4 Mini for cost-effective OCR text cleanup
- **Image Rotation:** Use CSS transforms for visual feedback, MiniMagick for processing (no persistent storage)
- **Development setup:** Requires `bin/dev` + separate `yarn build:css --watch` and `yarn build --watch` processes
