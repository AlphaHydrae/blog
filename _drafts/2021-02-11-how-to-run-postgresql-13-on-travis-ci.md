---
layout: post
title: How to run PostgreSQL 13 on Travis CI
date: '2021-02-11 21:51:47 +0100'
comments: true
today:
  type: learned
categories: programming
tags: testing
versions:
  travis-ci: 2021-02-11
  postgresql: 13.x
---

[Travis CI][travis-ci] is a continuous integration platform for open source. I
use it for all my open source projects that have an automated test suite (here's
[an example][gitload-builds]). Read about the [core
concepts][travis-ci-core-concepts] and [the tutorial][travis-ci-tutorial] if you
want to know more.

It supports [PostgreSQL][postgresql] as a database for your tests.
Unfortunately, according to the documentation at the time of writing, the
default integration is with PostgreSQL 9.2, a version that is no longer under
active development since November 2017. Versions 10 and later are also not as
well supported in that they require additional configuration to avoid [this
error][error]:

```bash
$ travis_setup_postgresql 13
Starting PostgreSQL v13
Assertion failed on job for postgresql@13-main.service.
sudo systemctl start postgresql@13-main
```

Let's see about fixing that.

<!-- more -->

The default PostgreSQL integration is enabled by adding the `postgresql` service
to your `.travis-ci.yml` file:

```yml
services:
  - postgresql
```

The documentation indicates what to do if you want to [use a different
version][travis-ci-postgresql-different-version]:

* Specify the version of the PostgreSQL addon.
* Install the appropriate APT package.
* Set the `PGPORT` environment variable to use a different port.

Here's the configuration fragment for PostgreSQL 13:

```yml
addons:
  postgresql: 13
  apt:
    packages:
      - postgresql-13
env:
  global:
    - PGPORT=5433
```

The documentation states that you can use the `postgres` user with a blank
password to access the PostgreSQL database. However when you're not using the
default PostgreSQL version, that's a lie (like the cake). You might get the
following error:

```
psql: error: FATAL:
Peer authentication failed for user "postgres"
```

[You have to update the configuration
yourself][travis-ci-postgresql-password-auth-failed]. For example, you can
modify [the `pg_hba.conf` file][postgresql-pg-hba] to use the `trust`
authentication method for local connections. That way you won't have to supply a
password at all:

```yml
before_install:
  # Use trust instead of peer authentication:
  - >-
    sudo sed -i
    -e '/local.*peer/s/postgres/all/'
    -e 's/peer\|md5/trust/g'
    /etc/postgresql/13/main/pg_hba.conf
  # Restart the PostgreSQL service:
  - sudo service postgresql@13-main restart
```

Finally, you can create your test database like you would with the default
PostgreSQL integration. You just have to specify the same custom port as the
`PGPORT` environment variable:

```yml
before_script:
  - sudo psql -p 5433 -U postgres -c 'create database my-app;'
```

Here's a full sample configuration for a hypothetical Node.js application:

```yml
language: node_js
node_js:
  - '10'
  - '12'
  - '14'

addons:
  # Use a different PostgreSQL version than the default:
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
    # A different port must be used when not using the
    # default PostgreSQL:
    - PGPORT=5433
  jobs:
    - NODE_ENV=test DB_PORT=5433 DB_USERNAME=postgres

before_install:
  # Use trust instead of peer authentication:
  - >-
    sudo sed -i
    -e '/local.*peer/s/postgres/all/'
    -e 's/peer\|md5/trust/g'
    /etc/postgresql/13/main/pg_hba.conf
  # Restart the PostgreSQL service:
  - sudo service postgresql@13-main restart

before_script:
  # Create the test database:
  - sudo psql -p 5433 -U postgres -c 'create database my-app;'
```

[error]: https://travis-ci.community/t/services-for-postgresql-11-and-12-fail-to-start-assertion-failed-on-job-for-postgresql-11-main-service/7069
[gitload-builds]: https://travis-ci.org/github/AlphaHydrae/gitload/builds
[postgresql]: https://www.postgresql.org
[postgresql-pg-hba]: https://www.postgresql.org/docs/13/auth-pg-hba-conf.html
[travis-ci]: https://travis-ci.org
[travis-ci-core-concepts]: https://docs.travis-ci.com/user/for-beginners
[travis-ci-postgresql]: https://docs.travis-ci.com/user/database-setup/#postgresql
[travis-ci-postgresql-different-version]: https://docs.travis-ci.com/user/database-setup/#using-a-different-postgresql-version
[travis-ci-postgresql-password-auth-failed]: https://github.com/travis-ci/travis-ci/issues/9624
[travis-ci-tutorial]: https://docs.travis-ci.com/user/tutorial/
