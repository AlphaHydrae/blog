---
layout: post
title: "Configuring Your SSH Client"
date: 2013-06-20 20:46
comments: true
categories: [ssh,workflow]
permalink: /:year/:month/:title/
---

I'm pretty bad at remembering IP addresses, and I'm too lazy to type the same
URLs over and over again. Such mundane tasks as connecting to my servers through
SSH should involve as little typing as possible. My mind immediately started
hacking a ruby script to handle that, but I managed to stop it just in time.
Phew.

_SSH has been around a while_, I thought. _There must be a configuration for that!_

`ssh_config` comes to the rescue...

<!-- more -->

In addition to command-line arguments, SSH reads configuration from
`~/.ssh/config` and `/etc/ssh/ssh_config`. This is a simple configuration:

```
Host eg
  HostName www.example.com
```

It instructs SSH to connect to the hostname `www.example.com` when you type `ssh
eg`.

When managing my servers, I need to connect as different users and with
different RSA keys. This is the kind of configuration I use:

```
Host h1
  HostName example1.com
  User myuser

Host h1r
  HostName example1.com
  User root
  IdentityFile /path/to/example1.com/id_rsa

Host h2
  HostName example2.com
  Port 42
```

`ssh h1` or `ssh h1r` will connect to `example1.com` either as an unprivileged
user or as root with a different identity file. `ssh h2` will connect to
`example2.com` on a custom port. And it's not limited to hostnames, user names
and ports. There are a lot of [other configuration
parameters](http://linux.die.net/man/5/ssh_config) for authentication,
compression, etc.

I've been using this for years now. It makes me feel better at every SSH
connection, knowing that I've saved a dozen characters. May the holy keyboard be
with you.

## Meta

* **ssh_config:** [Linux man page](http://linux.die.net/man/5/ssh_config)
