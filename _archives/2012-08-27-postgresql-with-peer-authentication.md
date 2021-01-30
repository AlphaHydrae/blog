---
layout: post
title: "PostgreSQL with peer authentication"
date: 2012-08-27 09:22
comments: true
permalink: /:year/:month/:title/
categories: sysadmin
tags: postgresql auth
versions:
  postgresql: 9.1.4
  fedora: 17
---

[{% img right /assets/contents/postgresql/logo.png 200 %}][postgresql]

PostgreSQL has always been my favorite SQL database, especially compared to
MySQL which I've always found a pain to configure for my uses. Peer
authentication allows to map OS user names to database user names for local
connections. It can be used for password-less database access in a multi-user
environment.

This guide shows how to install PostgreSQL and configure peer authentication on
Fedora.

<!--more-->

## Installation

```bash
# Install and run PostgreSQL.
yum install postgresql postgresql-devel \
            postgresql-server postgresql-contrib

# Initialize the database cluster.
mkdir -p /var/lib/pgsql/data
chown -R postgres:postgres /var/lib/pgsql/data
su postgres
  initdb -D /var/lib/pgsql/data -E UTF8 --locale=en_US.UTF8
```

If you install at a location other than `/var/lib/pgsql/data`, create this file
to tell the PostgreSQL service where to look:

```conf
# File: /etc/systemd/system/postgresql.service
.include /lib/systemd/system/postgresql.service
[Service]
Environment=PGDATA=/path/to/pgsql/data
```

The package provides a systemd service which you can enable on boot and start
like this:

```bash
systemctl enable postgresql.service
systemctl start postgresql.service
```

## Peer Authentication

By default, peer authentication allows each system user to authenticate as the
database user with the same name, but that's usually not sufficient for my
purposes. For example, I also want my `root` system user to be able to
authenticate as `postgres` (the godlike database user).

To do this, you must edit `pg_ident.conf` in the PostgreSQL data directory. Here
you can create user name maps like this one:

```conf
# MAPNAME    SYSTEM-USERNAME  PG-USERNAME
  adminmap   postgres         postgres
  adminmap   root             postgres
```

`SYSTEM-USERNAME` is the user name detected by the operating system.
`PG-USERNAME` is the database user name that this user should have. You must
group user name pairs under a `MAPNAME` which you will user later in the
authentication configuration. The map above defines that both the `postgres` and
`root` system users can connect as the `postgres` database user.

Once you have created your user name maps, you can use them in `pg_hba.conf`,
the authentication configuration file. Here is an example:

```conf
# TYPE   DATABASE  USER      ADDRESS  METHOD
  local  all       postgres           peer    map=adminmap
```

This defines that the `postgres` database user can access all databases. Notice
that we selected the peer authentication method and that we reference
`adminmap`, the user name map we created earlier. Therefore, with this
configuration both the `postgres` and `root` system users can connect to all
databases as `postgres`.

Now go forth and multiply the user name maps.

[postgresql]: http://www.postgresql.org
