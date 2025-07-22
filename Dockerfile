### ------- Builder ------- ###
ARG RUBY_VERSION=3.4.5
FROM ruby:${RUBY_VERSION}-alpine AS builder

ENV HOME=/app 
ENV RAILS_ENV=production 
ENV SECRET_KEY_BASE=abcdefgh12345678 
WORKDIR $HOME

ADD .ruby-version $HOME/
ADD Gemfile* $HOME/

RUN apk update && apk upgrade && \
    apk add --update --no-cache nodejs yarn build-base libxml2-dev tzdata postgresql-dev vips libffi-dev ruby-dev gcompat yaml-dev && \
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
FROM ruby:${RUBY_VERSION}-alpine

ENV HOME=/app 
ENV RAILS_ENV=production 
ENV SECRET_KEY_BASE=abcdefgh12345678
WORKDIR $HOME

RUN apk update && apk upgrade && \
    apk add --update --no-cache \
        nodejs tzdata imagemagick postgresql-client \
        tesseract-ocr tesseract-ocr-data-deu leptonica vips libffi && \
    rm -rf /var/cache/apk/* 

# Install gems
RUN gem update bundler && \
    bundle config set without 'development test' && \
    bundle config set --local deployment 'true' && \
    bundle config set --local path 'vendor/bundle'

COPY --from=builder /app /app

CMD bundle exec rails s -p 3000 -b '0.0.0.0'
