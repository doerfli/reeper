# Active Context

## Current Focus: Two-Phase AI Recognition (Mistral + OpenAI)
**Branch**: `feature/mistral-ai-ocr`
**Recent Activity**: Implemented two-phase AI recognition with Mistral OCR and OpenAI parsing

## Overview
The two-phase AI recognition feature has been successfully implemented, allowing users to choose between "OpenAI Direct" (image → recipe) and "Mistral + OpenAI" (image → markdown → recipe) methods. This provides flexibility in AI processing and enables comparison of different OCR approaches.

## Recently Completed
- ✅ Added `ai_method` column to `ocr_results` table (migration)
- ✅ Created `OpenaiService#parse_markdown_to_recipes` method
- ✅ Updated `OcrController#scan` with two-phase logic
- ✅ Updated `OcrController#reparse_image` with two-phase logic
- ✅ Added AI method dropdown selector to upload view
- ✅ Added AI method dropdown selector to reparse view
- ✅ Updated JavaScript controllers to handle method selection
- ✅ Added translations (EN/DE) for AI method options
- ✅ Mistral + OpenAI set as default method

## Current State
- On `feature/mistral-ai-ocr` branch
- Two-phase feature fully implemented
- Ready for testing and merge
- All error handling in place (fails entirely on two-phase errors)

## Active Implementation

### Two-Phase AI Recognition (✅ COMPLETED)
All implementation completed:

1. **Database**: `ai_method` string column in `ocr_results` (default: 'openai_direct')
2. **OpenAI Service**: New `parse_markdown_to_recipes` method using `recipe_markdown_prompt_id`
3. **OCR Controller**: Conditional logic for `mistral_openai` vs `openai_direct`
4. **Upload View** (`new_magic.html.erb`): Dropdown for AI method selection
5. **Reparse View** (`select_image_for_reparse.html.erb`): Dropdown for AI method selection
6. **JavaScript**: Updated dropzone and reparse controllers
7. **Locales**: EN/DE translations for "Mistral + OpenAI" and "OpenAI Direct"

### How It Works
- **Mistral + OpenAI**: Image → Mistral OCR (markdown) → OpenAI parse (structured recipe JSON)
- **OpenAI Direct**: Image → OpenAI (structured recipe JSON)
- **Error Handling**: Two-phase process fails entirely if either step fails (no partial results)
- **Tracking**: `ai_method` stored in `OcrResult` for debugging/auditing

## Active Dependencies
- OpenAI API with two prompts (ocr and markdown parsing)
- Mistral AI OCR service via OmniAI gem
- OcrResult model with `ai_method` tracking
- Ruby 3.4.8
- Rails 8.x
- Auth0 for authentication
- AWS S3 for file storage

## Next Steps
1. 🧪 Test two-phase recognition with various recipe images
2. 📊 Compare accuracy between Mistral+OpenAI vs OpenAI Direct
3. 🔄 Merge to main once testing complete
4. 📝 Update documentation with new feature
5. 🎯 Monitor performance and cost of both methods in production

## Known Issues
- None currently - feature fully implemented and ready for testing

## Notes
- Mistral + OpenAI is the default method
- Users can switch between methods in both upload and reparse flows
- Same UI styling applied to both upload and reparse views
- Backward compatible - existing records default to 'openai_direct'
