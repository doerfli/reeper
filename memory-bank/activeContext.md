# Active Context

## Current Feature: Multiple Recipes Support in OCR
**Branch**: `feature/multiple-recipes-support`
**PR**: #734 - Feature/multiple-recipes-support

## Overview
Enhancing the AI OCR functionality to support extraction and selection of multiple recipes from a single image. When an image contains multiple recipes, users can now select which recipe to import.

## Active Components
- Multiple recipes detection and parsing
- Recipe selection UI workflow
- Flash data management for recipe selection
- Reparse flow integration for existing recipes
- OpenAI prompt updates to support multi-recipe extraction

## Current State
- Feature branch: `feature/multiple-recipes-support`
- Pull request #734 is **OPEN** (awaiting review)
- All CI/CD checks passing (Docker, Ruby tests, Dependency review)
- Implementation complete, ready for thorough review

## Implementation Details

### Changes Made
1. **OpenAI Service** (`app/services/openai_service.rb`)
   - Modified to parse response as array of recipes
   - Extracts `recipes` array from JSON response
   - Returns array instead of single recipe object

2. **OCR Controller** (`app/controllers/ocr_controller.rb`)
   - Added `show_recipe_selection` action to display recipe choices
   - Added `select_recipe` action to handle user's selection
   - Modified `scan` method to detect multiple recipes and redirect accordingly
   - Modified `reparse_image` method to handle multiple recipes in reparse flow
   - Flash storage now includes both `ocr_data` ID and `recipe_index`

3. **Recipes Controller** (`app/controllers/recipes_controller.rb`)
   - Updated `new` and `edit` actions to retrieve selected recipe by index
   - Parses recipes array and extracts recipe at `recipe_index`

4. **New View** (`app/views/ocr/show_recipe_selection.html.erb`)
   - Simple UI for selecting from multiple detected recipes
   - Displays recipe titles with clickable buttons
   - Handles both new recipe and reparse workflows

5. **Routes** (`config/routes.rb`)
   - Added GET route: `select_recipe_ocr_path(:id)`
   - Added POST route: `select_recipe_ocr_index_path`

6. **Configuration** (`config/initializers/openai.rb`)
   - Updated OpenAI prompt ID to version that returns multiple recipes
   - New prompt ID: `pmpt_694514e453388194a1e4c121407ef02204bec5d20e21b070` (version 2)

7. **Locales** (i18n)
   - Added German and English translations for recipe selection UI
   - Keys: `ocr.select_recipe.title`, `description`, `untitled`, `not_found`

8. **Copilot Rules**
   - Added internationalization rule for consistent i18n usage

## Dependencies
- OpenAI API with updated multi-recipe prompt
- OcrResult model for temporary storage
- Flash data for cross-request state management

## Next Steps
1. ✅ Complete implementation (DONE)
2. 🔍 Thorough code review for edge cases
3. ✅ All CI/CD checks passing
4. 📝 Review PR #734 comments/feedback
5. 🧪 Manual testing of both workflows (new recipe + reparse)
6. 🚀 Merge to main after approval

## Known Issues to Watch
- **Test suite has dependency issue**: `chromedriver-helper` gem incompatibility with Ruby 3.4.8/Selenium
- **Empty array handling**: Service uses `rescue []` for JSON parsing - should validate more explicitly
- **No nil checks**: Recipe selection doesn't validate if `recipe_index` is out of bounds for array
- **Sparse test coverage**: `spec/controllers/ocr_controller_spec.rb` is empty

## Notes
- Feature enhances existing magic recipe functionality
- Maintains backward compatibility for single-recipe images
- Reparse flow properly integrated with recipe selection
- Flash-based state management avoids session size issues
