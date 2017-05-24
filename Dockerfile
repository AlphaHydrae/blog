FROM ruby:2.3

LABEL maintainer="docker@alphahydrae.com"

ENV LANG="C.UTF-8"

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY Gemfile Gemfile.lock /usr/src/app/
RUN bundle install

COPY . /usr/src/app
RUN rake generate

RUN apt-get update -qq \
    && apt-get install -q -y rsync

CMD [ "rsync", "-avze", "--delete", "/usr/src/app/public/", "/var/www/dist" ]
