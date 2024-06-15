---
layout: post
title: "Git: how to commit often and still push"
date: 2012-08-14 09:03
comments: true
permalink: /:year/:month/:title/
categories: tooling
versions:
  git: 1.x
---

I usually like to [rewrite my commit history][git-rewriting-history] since I
commit a lot. It makes it look more organized. But I also want to push my "dirty
commits" to a server so I don't have to worry about my laptop burning; it's a
cheap backup.

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

Let's start by adding our remotes. Read my article about [*setting up your own
Git server*][set-up-your-own-git-server] if you don't know how to do it.

```bash
git remote add origin git@github.com:myuser/myrepo.git
git remote add dirty git@myserver.com:myrepo.git
```

Now you can set up a dirty branch to play in.

```bash
git checkout develop
git checkout -b ohyeah
git push dirty ohyeah
```

After some time you will want to transform your haphazard pile of changes into a
beautiful and well-documented commit. Say you want to interactively rebase the
dirty branch so you can squash some commits together. Assuming you branched from
develop, you can do this:

```bash
git rebase -i develop ohyeah
```

Your branch is now clean. You can push it to the public server, or merge it to
develop and push that. If you want to create a new clean branch and keep the
dirty one.

```bash
# Switch to your dirty branch.
git checkout ohyeah

# Create the to-be-cleaned branch.
git checkout -b myFeature

# Rebase (assuming you branched ohyeah from develop).
git rebase -i develop myFeature

# You now have a clean myFeature branch.
```

Just be careful with this last solution. Once you've rewritten your new branch,
it can't share any new commits with the dirty one, since they now have a
different history.

Enjoy.

[git-rewriting-history]: https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History
[set-up-your-own-git-server]: /2012/08/set-up-your-own-git-server/
