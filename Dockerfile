### ------- Builder ------- ###
FROM ruby:3.1.0-alpine as builder

ENV HOME=/app \
    RAILS_ENV=production \
    RAILS_SERVE_STATIC_FILES=true \
    SECRET_KEY_BASE=abcdefgh12345678 
WORKDIR $HOME

ADD .ruby-version $HOME/
ADD Gemfile* $HOME/

RUN apk update && apk upgrade && \
    apk add --update --no-cache nodejs yarn build-base libxml2-dev tzdata postgresql-dev && \
    rm -rf /var/cache/apk/* 

# # speed up install of nokogiri gem
RUN gem update bundler && \
    bundle config --local build.nokogiri --use-system-libraries && \
    bundle config set without 'development test' && \
    bundle config set --local deployment 'true' && \
    bundle config set --local path 'vendor/bundle' && \
    bundle install --jobs 4

# Add the app code
COPY . $HOME

RUN yarn install && \
    bundle exec rake assets:precompile

# delete unneeded files
RUN rm -rf node_modules tmp/cache vendor/assets spec


### ------- Production ------- ###
FROM ruby:3.1.0-alpine

ENV HOME=/app \
    RAILS_ENV=production \
    RAILS_SERVE_STATIC_FILES=true \
    SECRET_KEY_BASE=abcdefgh12345678
WORKDIR $HOME

RUN apk update && apk upgrade && \
    apk add --update --no-cache \
        nodejs tzdata imagemagick postgresql-client \
        tesseract-ocr tesseract-ocr-data-deu leptonica && \
    rm -rf /var/cache/apk/* 

# Install gems
RUN gem update bundler && \
    bundle config set --local deployment 'true' && \
    bundle config set --local path 'vendor/bundle'

COPY --from=builder /app /app
