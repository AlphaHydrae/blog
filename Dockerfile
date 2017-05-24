FROM ruby:2.3

LABEL maintainer="docker@alphahydrae.com"

ENV LANG="C.UTF-8"

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY Gemfile Gemfile.lock /usr/src/app/
RUN bundle install

COPY . /usr/src/app
RUN rake generate

CMD [ "cp", "-R", "/usr/src/app/.", "/var/www/dist/" ]
