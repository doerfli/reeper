# Reeper

This repository contains a self-hosted recipe web application implemented in Ruby On Rails. 

Runtime docker images are available. 

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


## Start development server

Start webpack-dev-server, css build, rails

```
bin/dev
```

## Start production via docker

Use provided `docker-compose.prod.yml` file for startup of postgres db and container for the rails app. Don't forget to set `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and db passwords. To change name of S3 bucket (_reeper_) and region (_eu-central-1_) use `S3_BUCKET_NAME` and `S3_BUCKET_REGION` environment variables. 

