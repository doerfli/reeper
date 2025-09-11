# GPT OCR Cleanup Feature

## Overview
AI-powered text cleanup for OCR results using OpenAI's GPT-4 Mini model, specifically optimized for recipe content from cookbook/magazine photos.

## Feature Details

### User Experience
- **Location:** OCR interface (`/ocr/:id`)
- **Trigger:** "Cleanup with AI" / "Mit KI bereinigen" button
- **Position:** Between "Copy to clipboard" and "Save to Recipe" buttons
- **Feedback:** Loading spinner during processing, success state on completion

### Technical Implementation

#### Files Created/Modified
1. **View:** `app/views/ocr/_imgregion.html.erb` - Added cleanup button
2. **Controller:** `app/controllers/ocr_controller.rb` - Added `cleanup_with_gpt` action
3. **Service:** `app/services/openai_cleanup_service.rb` - OpenAI integration service
4. **JavaScript:** `app/javascript/controllers/ocr_selection_controller.js` - Frontend functionality
5. **Routes:** `config/routes.rb` - Added cleanup endpoint
6. **Locales:** English/German translations added
7. **Dependencies:** Added `ruby-openai` gem to Gemfile

#### API Integration
- **Model:** GPT-4 Mini (`gpt-4o-mini`)
- **Max Tokens:** 2000 (cost optimization)
- **Temperature:** 0.3 (consistent, focused responses)
- **Authentication:** API key stored in Rails credentials

### Language-Specific Prompts

#### German (deu)
"Du bist ein Assistent zur OCR-Text-Bereinigung für Rezepte. Der folgende Text wurde mittels OCR aus einem Foto eines Kochbuchs oder einer Kochzeitschrift erkannt und enthält wahrscheinlich Rezepte, Zutaten oder Kochanweisungen. Bitte bereinige den Text, indem du Rechtschreibfehler korrigierst, die Formatierung verbesserst und den Text lesbarer machst, während du die ursprüngliche Bedeutung beibehältst. Achte besonders auf typische Küchenbegriffe, Mengenangaben und Zubereitungsschritte. Antworte auf Deutsch:"

#### English (eng)
"You are an OCR text cleanup assistant for recipes. The following text was recognized via OCR from a photo of a cookbook or cooking magazine and likely contains recipes, ingredients, or cooking instructions. Please clean up the text by fixing spelling errors, improving formatting, and making it more readable while preserving the original meaning. Pay special attention to typical cooking terms, measurements, and preparation steps. Respond in English:"

### Error Handling
- **Missing API Key:** Service raises descriptive error
- **Network Issues:** Frontend displays user-friendly error messages
- **API Errors:** Graceful degradation with error feedback

### Cost Considerations
- **Model Choice:** GPT-4 Mini for cost efficiency
- **Token Limit:** 2000 tokens max per request
- **Temperature:** Low (0.3) for deterministic responses

## Configuration

### OpenAI API Key

#### Development
Two options available:
1. **Environment Variable (Recommended)**:
   ```bash
   export OPENAI_API_KEY=your_openai_api_key_here
   ```
   
2. **Rails Credentials**:
   ```bash
   EDITOR="code --wait" rails credentials:edit
   ```
   Add:
   ```yaml
   openai_api_key: your_openai_api_key_here
   ```

#### Production (Docker/Dokku)
Set environment variable:
```bash
# Set the OpenAI API key for your app
dokku config:set your-app-name OPENAI_API_KEY=your_actual_openai_api_key_here

# Verify configuration
dokku config:show your-app-name
```

#### Priority
The service checks for API key in this order:
1. `OPENAI_API_KEY` environment variable (production)
2. `Rails.application.credentials.openai_api_key` (development fallback)

### Routes
```ruby
resources :ocr do
  member do
    post 'cleanup_with_gpt'
  end
end
```

## Usage Workflow
1. User performs OCR on recipe image
2. User selects language (German/English)
3. User clicks "Cleanup with AI" button
4. System sends OCR text + language-specific prompt to GPT-4 Mini
5. Cleaned text replaces original content in textarea
6. User can then save cleaned text to recipe

## Benefits
- **Accuracy:** Fixes OCR recognition errors
- **Context-Aware:** Understands cooking terminology and measurements
- **Language-Specific:** Tailored prompts for German/English content
- **User-Friendly:** Seamless integration into existing workflow
- **Cost-Effective:** Uses efficient GPT-4 Mini model

## Monitoring
- API usage should be monitored for cost control
- Error rates should be tracked for reliability
- User adoption metrics to measure feature value
