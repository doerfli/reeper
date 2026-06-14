# Reeper

This repository contains a self-hosted recipe web application implemented in Ruby On Rails. 

Runtime docker images are available.

## Requirements

- Ruby 3.4+
- PostgreSQL
- ImageMagick
- Redis (required for Sidekiq background jobs)
  - Recommended: Redis 6+
  - Start locally: `docker run --rm -p 6379:6379 redis:6`

## Features

- Recipe management with images and OCR text recognition
- **AI-powered recipe extraction with two methods:**
  - **Mistral + OpenAI**: Image → Mistral OCR (markdown) → OpenAI parsing (structured recipe)
  - **OpenAI Direct**: Image → OpenAI (structured recipe)
- AI-powered OCR text cleanup using GPT-4 Mini
- Multiple recipes detection from single image
- Tagging and search functionality
- Auth0 authentication
- AWS S3 file storage
- Responsive UI with Tailwind CSS 

## Preparation for development

### DB Setup

```
rake db:create
rake db:migrate
```

Restore dump

```
pg_restore -d reeper_development -h db -Upostgres file.dump
```

### AWS credentials

Create `.env.local` file with AWS credentials

```bash
# .env.local
AWS_ACCESS_KEY_ID=AAAAAAA
AWS_SECRET_ACCESS_KEY=BBBBB
```

### OpenAI API Key (for AI recipe extraction and OCR cleanup)

For the AI-powered recipe extraction and OCR cleanup features, configure your OpenAI API key:

**Development:**
```bash
# Option 1: Environment variable (recommended)
export OPENAI_API_KEY=your_openai_api_key_here

# Option 2: Rails credentials
EDITOR="code --wait" rails credentials:edit
# Add: openai_api_key: your_openai_api_key_here
```

**Production/Dokku:**
```bash
dokku config:set your-app-name OPENAI_API_KEY=your_actual_openai_api_key_here

# Optional: Override cleanup prompts per language
dokku config:set your-app-name OPENAI_CLEANUP_PROMPT_EN="Your custom English prompt..."
dokku config:set your-app-name OPENAI_CLEANUP_PROMPT_DE="Your custom German prompt..."
```

**Optional Configuration:**
- `OPENAI_CLEANUP_PROMPT_EN`: Override the default English cleanup prompt
- `OPENAI_CLEANUP_PROMPT_DE`: Override the default German cleanup prompt
- `OPENAI_OCR_MODEL`: Override the OpenAI model used for direct OCR (default: `gpt-5.4-nano`)
- `OPENAI_OCR_PROMPT_FILE`: Override the prompt file (in `config/prompts/`) used for direct OCR (default: `openai_ocr.txt`)
- `OPENAI_MARKDOWN_MODEL`: Override the OpenAI model used for markdown parsing (default: `gpt-5.4-nano`)
- `OPENAI_MARKDOWN_PROMPT_FILE`: Override the prompt file used for markdown parsing (default: `openai_markdown.txt`)
- `OPENAI_URL_MODEL`: Override the OpenAI model used for URL import parsing (default: `gpt-5.4-nano`)
- `OPENAI_URL_PROMPT_FILE`: Override the prompt file used for URL import parsing (default: `openai_url.txt`)

### Mistral AI API Key (for two-phase OCR)

For the Mistral + OpenAI two-phase recipe extraction, configure your Mistral AI API key:

**Development:**
```bash
export MISTRAL_API_KEY=your_mistral_api_key_here
```

**Production/Dokku:**
```bash
dokku config:set your-app-name MISTRAL_API_KEY=your_actual_mistral_api_key_here
```

**Note:** The Mistral API key is only required if you plan to use the "Mistral + OpenAI" recognition method. The "OpenAI Direct" method only requires the OpenAI API key. 

### Jina AI API Key (for URL import)

For the URL-based recipe import feature, the app fetches web page content via [Jina.ai reader](https://jina.ai/reader/). No API key is required for basic (free tier) usage.

**Development:**
```bash
# Optional: set for authenticated/paid-tier usage
export JINA_API_KEY=your_jina_api_key_here
```

**Production/Dokku:**
```bash
# Optional
dokku config:set your-app-name JINA_API_KEY=your_actual_jina_api_key_here
```

**Note:** Without `JINA_API_KEY` the free unauthenticated tier is used. Set the key to use your Jina.ai account quota and higher rate limits.


## Start development server

Start dev-server, css build, js build

```
bin/dev
yarn build:css --watch
yarn build --watch
```

## Start production via docker

Use provided `docker-compose.prod.yml` file for startup of postgres db and container for the rails app. Don't forget to set the following environment variables:

**Required:**
- `AWS_ACCESS_KEY_ID`: AWS access key
- `AWS_SECRET_ACCESS_KEY`: AWS secret key
- `OPENAI_API_KEY`: OpenAI API key for AI recipe extraction
- `MISTRAL_API_KEY`: Mistral AI API key (required for Mistral + OpenAI method)
- `JINA_API_KEY`: Jina.ai API key (optional, for authenticated URL import)
- Database passwords

**Optional:**
- `MISTRAL_API_KEY`: Mistral AI API key (only needed for "Mistral + OpenAI" method)
- `S3_BUCKET_NAME`: Override S3 bucket name (default: _reeper_)
- `S3_BUCKET_REGION`: Override S3 region (default: _eu-central-1_)
- `OPENAI_OCR_MODEL` / `OPENAI_OCR_PROMPT_FILE`: Custom model/prompt file for direct OCR
- `OPENAI_MARKDOWN_MODEL` / `OPENAI_MARKDOWN_PROMPT_FILE`: Custom model/prompt file for markdown parsing
- `OPENAI_URL_MODEL` / `OPENAI_URL_PROMPT_FILE`: Custom model/prompt file for URL import parsing

