---
layout: post
title: "Full-HTTPS Octopress Blog"
date: 2013-01-27 20:03
comments: false
categories: [https, octopress]
---

I wanted this blog to be served over HTTPS for now, but I noticed that there was some HTTP content left after I set up the web server, which makes some browsers feel insecure.

The culprits were **Twitter** and **Google Fonts**. This is the list of URLs I had to change to `https://`. There may be more if you use other features such as Delicious or Google Plus.

* `http://twitter.com/...` in `source/_includes/asides/twitter.html` (two URLs)
* `http://platform.twitter.com/...` in `source/_includes/twitter_sharing.html` (one URL)
* `http://fonts.googleapis.com/...` in `source/_includes/custom/head.html` (two URLs)
