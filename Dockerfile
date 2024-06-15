# Builder image
# =============
FROM ruby:3.3.3-alpine3.20 AS builder

LABEL maintainer="docker@alphahydrae.com"

ENV JEKYLL_ENV=production

WORKDIR /usr/src/app

RUN apk add --no-cache bash g++ make nodejs npm && \
    node --version && \
    addgroup -S blog && \
    adduser -D -g blog -S blog && \
    chown blog:blog /usr/src/app

USER blog:blog

COPY --chown=blog:blog Gemfile Gemfile.lock /usr/src/app/

RUN echo 'gem: --no-rdoc --no-ri' > /home/blog/.gemrc && \
    bundle install

COPY --chown=blog:blog package.json package-lock.json /usr/src/app/

RUN npm ci

COPY --chown=blog:blog ./ /usr/src/app/

RUN bundle exec jekyll build

# Production image
# ================
FROM nginx:1.27.0-alpine

WORKDIR /usr/share/nginx/html

COPY --chown=nobody:nobody --from=builder /usr/src/app/_site/ /usr/share/nginx/html/
