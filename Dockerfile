FROM ruby:3.0.3-alpine

RUN apk update && apk upgrade && \
    apk add --update nodejs yarn git build-base libxml2 libxml2-dev libxml2-utils libxslt-dev tzdata imagemagick && \
    apk add libc6-compat sassc libsass && \
    apk add postgresql-dev postgresql-client && \
    apk add tesseract-ocr  tesseract-ocr-dev tesseract-ocr-data-deu leptonica leptonica-dev && \
    rm -rf /var/cache/apk/*

ENV HOME /app
ENV RAILS_SERVE_STATIC_FILES true
ENV SECRET_KEY_BASE abcdefgh12345678

WORKDIR $HOME

# Install gems
COPY .ruby-version $HOME/
COPY Gemfile* $HOME/
RUN gem update bundler
RUN bundle config --local build.nokogiri --use-system-libraries
RUN bundle install --jobs 4

# install node dependencies
COPY package.json $HOME/
COPY yarn.lock $HOME/
RUN yarn

# Add the app code
ADD . $HOME
VOLUME $HOME
