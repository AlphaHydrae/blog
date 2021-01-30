---
layout: post
title: "Git: how to commit often and still push"
date: 2012-08-14 09:03
comments: true
categories: [git, workflow]
---

I usually like to [rewrite my commit
history](http://git-scm.com/book/ch6-4.html) since I commit a lot. It makes it
look more organized. But I also want to push my "dirty commits" to a server so I
don't have to worry about my laptop burning; it's a cheap backup.

Git doesn't normally let you rebase commits that have already been pushed. It's
because rewriting a public branch is nothing but a good way to make enemies. But
I still want to do both: push for backup and then rewrite history.

<!--more-->

## Here Be Dragons

My solution is to work with both a public and a private Git server.

The idea is to work with a commit-often workflow on your private server that
nobody can see. These are the dirty commits. Once you have something that works
that you can push to the public server, you can rewrite your dirty commits into
a clean branch and push that.

Let's start by adding our remotes. Read my article about [setting up your own
Git server](/2012/08/set-up-your-own-git-server/) if you don't know how to do
it.

{% highlight bash %}
git remote add origin git@github.com:myuser/myrepo.git
git remote add dirty git@myserver.com:myrepo.git
{% endhighlight %}

Now you can set up a dirty branch to play in.

{% highlight bash %}
git checkout develop
git checkout -b ohyeah
git push dirty ohyeah
{% endhighlight %}

After some time you will want to transform your haphazard pile of changes into a
beautiful and well-documented commit. Say you want to interactively rebase the
dirty branch so you can squash some commits together. Assuming you branched from
develop, you can do this:

{% highlight bash %}
git rebase -i develop ohyeah
{% endhighlight %}

Your branch is now clean. You can push it to the public server, or merge it to
develop and push that. If you want to create a new clean branch and keep the
dirty one.

{% highlight bash %}
# switch to your dirty branch
git checkout ohyeah

# create the to-be-cleaned branch
git checkout -b myFeature

# rebase (assuming you branched ohyeah from develop)
git rebase -i develop myFeature

# you now have a clean myFeature branch
{% endhighlight %}

Just be careful with this last solution. Once you've rewritten your new branch,
it can't share any new commits with the dirty one, since they now have a
different history.

Enjoy.
