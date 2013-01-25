---
layout: post
title: "Git: how to commit often and still push"
date: 2012-08-14 09:03
comments: false
categories: 
---

There's something that's always bugged me in my Git workflow.

1. I like to commit early and commit often.
2. When you commit often, you also want to rewrite your history a bit using such fine tools as rebase, cherry-pick, etc. That way it looks like you're organized.
3. Pushing all my commits to the server is nice. I don't have to worry about my laptop burning, hard drive failures or unsolicited meteors. It's a cheap backup.

2 and 3 mixed together are not good on a public server. You don't want to rewrite history on a public branch unless your goal is to make enemies. But I still want to do both.

## Here Be Dragons

My solution is to work with both a public and a private Git server.

The idea is that you work with your commit-often workflow on your private server that nobody can see. These are the dirty commits.

Once you have something that works that you want to push to the public server, you can rewrite your dirty commits into a clean branch and push that.

Let's start by adding our remotes. Read my article about setting up your own private Git server if you don't know how to do it.

{% codeblock %}
git remote add origin git@github.com:myuser/myrepo.git
git remote add dirty git@myserver.com:myrepo.git
{% endcodeblock %}

Now you can set up a dirty branch to play in.

{% codeblock %}
git checkout develop
git checkout -b ohyeah
git push dirty ohyeah
{% endcodeblock %}

Let's party! Do the coding dance!

After some time you should feel ridiculous enough and have enough commits. At this stage, you probably want to transform your haphazard pile of changes into a beautiful and well-documented commit.

Say you want to interactively rebase the dirty branch so you can squash some commits together. Assuming you branched from develop, you can do this:

{% codeblock %}
git rebase -i develop ohyeah
{% endcodeblock %}

Your branch is now clean. You can push it to the public server, or merge it to develop and push that,

If you want to create a new clean branch and keep the dirty one.

{% codeblock %}
# switch to your dirty branch
git checkout ohyeah
 
# create the to-be-cleaned branch
git checkout -b myFeature
 
# rebase (assuming you branched ohyeah from develop)
git rebase -i develop myFeature
 
# you now have a clean myFeature branch
{% endcodeblock %}

Just be careful with this last solution. Once you've rewritten your new branch, it can't share any new commits with the dirty one, since they now have a different history.

Enjoy.
