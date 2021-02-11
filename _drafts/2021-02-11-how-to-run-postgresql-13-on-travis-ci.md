---
layout: post
title: How to run PostgreSQL 13 on Travis CI
date: '2021-02-11 15:44:47 +0100'
comments: true
today:
  type: learned
categories: programming
tags: travis-ci testing
versions:
  postgresql: 13.x
---

Hello, World!

<!-- more -->

https://travis-ci.community/t/services-for-postgresql-11-and-12-fail-to-start-assertion-failed-on-job-for-postgresql-11-main-service/7069

```yml
language: node_js
node_js:
  - '8'
  - '10'
  - '12'
  - '14'
addons:
  # Use a different PostgreSQL version than the default:
  # https://docs.travis-ci.com/user/database-setup/#using-a-different-postgresql-version.
  postgresql: 13
  apt:
    update: true
    packages:
      - postgresql-13
      - postgresql-13-postgis-3
services:
  - postgresql
env:
  global:
    # A different port must be used when not using the default PostgreSQL.
    - PGPORT=5433
  jobs:
    - NODE_ENV=test DATABASE_PORT=5433 DATABASE_USERNAME=postgres SECRET=travis
before_install:
  # Fix PostgreSQL authentication because version 13 is not supported out of the
  # box: https://github.com/travis-ci/travis-ci/issues/9624.
  - sudo sed -i -e '/local.*peer/s/postgres/all/' -e 's/peer\|md5/trust/g' /etc/postgresql/13/main/pg_hba.conf
  - sudo service postgresql@13-main restart
  - sleep 1
before_script:
  # Create the database with the PostGIS extension.
  - sudo psql -p 5433 -U postgres -c 'create database biosentiers;'
  - sudo psql -p 5433 -U postgres -c 'create extension postgis;' biosentiers
  # Migrate the database.
  - npm run migrate:test
after_success:
  # Send test coverage to coveralls.
  - npm run test:coverage
```

https://docs.travis-ci.com/user/database-setup/#using-a-different-postgresql-version
