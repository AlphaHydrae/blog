---
layout: post
title: "Git: how to log commits from all branches"
date: 2013-01-25 20:56
comments: true
categories: [git]
permalink: /:year/:month/:title/
---

By default, the `git log` command will only show commits reachable from
**HEAD**.

{% highlight text %}
A---B---C---D (master)
     \
      \-E---F (HEAD, develop)
{% endhighlight %}

{% highlight text %}
$> git log --oneline --graph --decorate
* f536261 (HEAD, develop) F
* 1c49789 E
* 0f00043 B
* 5f8165a A
{% endhighlight %}

To also show commits from other branches, you have to add the `--all` option.

{% highlight text %}
$> git log --oneline --graph --decorate --all
* f536261 (HEAD, develop) F
* 1c49789 E
| * e384c0c (master) D
| * 826c7a6 C
|/
* 0f00043 B
* 5f8165a A
{% endhighlight %}
