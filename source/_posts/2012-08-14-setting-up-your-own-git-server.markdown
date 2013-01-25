---
layout: post
title: "Setting up your own Git server"
date: 2012-08-14 08:28
comments: false
categories: [git]
---

In addition to GitHub, I like having a private copy of my repositories on one of my own servers. It serves both as a secondary backup, and also to play with pushed commits as I'll explain in a future post. The idea is to set up a server that we'll access with SSH in the same way as GitHub, with a remote that looks like `git@myserver.com:myrepo.git`, and with public key authentication.

## Setup

{% codeblock lang:bash First, let's make sure Git is installed %}
# Fedora 17
yum install git-all # ("-all" sounds like it has what we need)
 
# Ubuntu 11
apt-get install git
{% endcodeblock %}

Next, we need to set up a Git user. We want this user to be only usable for Git, so we'll restrict its shell. On Fedora 17, the shell we want is `/bin/git-shell`. Run `which git-shell` if you're not sure where it is.

{% codeblock lang:bash Create a Git user %}
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
{% endcodeblock %}

And your Git user is ready. Everyone who needs access must have their public key in `/home/git/.ssh/authorized_keys`.

## Usage

{% codeblock lang:bash How to add a repository %}
# create bare repo (as the git user)
su -s /bin/bash git
    cd
    mkdir myrepo.git && cd myrepo.git
    git init --bare
{% endcodeblock %}

{% codeblock lang:bash How to configure the remote %}
# add the remote with the correct domain and repo
git remote add myremote git@myserver.com:myrepo.git
git push myremote master
{% endcodeblock %}

You can now push your secret commits in the privacy of your own server.

## Meta

* **OS:** Fedora 17
* **Git:** 1.7.11.2
