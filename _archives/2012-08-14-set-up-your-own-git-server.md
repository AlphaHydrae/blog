---
layout: post
title: "Set up your own Git server"
date: 2012-08-14 08:28
comments: true
categories: [git]
permalink: /:year/:month/:title/
---

In addition to GitHub, I like having a private copy of my repositories on one of
my own servers. It serves both as a secondary backup, and also to play with
pushed commits as I'll explain in a future post. The idea is to set up a server
that can be accessed through SSH in the same way as GitHub, with a remote that
looks like `git@myserver.com:myrepo.git`, and with public key authentication.

<!--more-->

## Setup

Install Git:

{% highlight bash %}
# Fedora 17
yum install git-all

# Ubuntu 11
apt-get install git
{% endhighlight %}

Next, we need a Git user. We want this user to only have access to Git, so we'll
restrict his shell. On Fedora 17, the shell we want is `/bin/git-shell`. Run
`which git-shell` if you're not sure where it is.

{% highlight bash %}
# create the user (the -d option specifies the home directory)
useradd -m -d /home/git git

# you must allow the git shell to be used on your system
vim /etc/shells
    # add this line
    /bin/git-shell

# set the git user's shell
usermod -s /bin/git-shell git

# set up public key authentication (as the git user)
su -s /bin/bash git
    cd
    mkdir .ssh && chmod 700 .ssh && cd .ssh
    touch authorized_keys && chmod 600 authorized_keys
{% endhighlight %}

And your Git user is ready. Everyone who needs access must have their public key
in `/home/git/.ssh/authorized_keys`.

## Usage

Add a repository on your server:

{% highlight bash %}

# create bare repo (as the git user)
su -s /bin/bash git
    cd
    mkdir myrepo.git && cd myrepo.git
    git init --bare
{% endhighlight %}

Configure the remote on a repo:

{% highlight bash %}
# add the remote with the correct domain and repo
git remote add myremote git@myserver.com:myrepo.git
git push myremote master
{% endhighlight %}

You can now push your secret commits in the privacy of your own server.

## Meta

* **OS:** Fedora 17
* **Git:** 1.7.11.2