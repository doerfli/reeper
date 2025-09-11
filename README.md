# Reeper

This repository contains a self-hosted recipe web application implemented in Ruby On Rails. 

Runtime docker images are available.

## Features

- Recipe management with images and OCR text recognition
- AI-powered OCR text cleanup using GPT-4 Mini
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

### OpenAI API Key (for OCR text cleanup)

For the GPT-powered OCR text cleanup feature, configure your OpenAI API key:

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
```


## Start development server

Start dev-server, css build, js build

```
bin/dev
yarn build:css --watch
yarn build --watch
```

## Start production via docker

Use provided `docker-compose.prod.yml` file for startup of postgres db and container for the rails app. Don't forget to set `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `OPENAI_API_KEY` and db passwords. To change name of S3 bucket (_reeper_) and region (_eu-central-1_) use `S3_BUCKET_NAME` and `S3_BUCKET_REGION` environment variables. 

