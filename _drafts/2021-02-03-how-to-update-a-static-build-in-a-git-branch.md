---
layout: post
title: How to update a static build in a Git branch
date: '2021-02-03 21:59:00 +0100'
comments: true
today:
  type: learned
categories: programming
versions:
  git: 2.30.0
---

[Static site generators][static-site-generators] like [Jekyll][jekyll] or
[Hugo][hugo] ingest Markdown and other such files and data to produce a static
site that you can then host wherever you want. One free deployment option is
[GitHub Pages][github-pages]. You just commit the static files to a branch, push
to GitHub, and GitHub Pages serves them for you either under `*.github.io` or
under a custom domain if you have one.

<!-- more -->

This procedure explains a convoluted way of updating your branch when you have a
new version of your static site to deploy. Because why do things the easy way
when you can do them the hard way?

1. Initialize an empty repository somewhere:

   ```bash
   cd /path/to/example
   git init
   ```
1. Add the GitHub Pages repository as a remote and fetch, *but do not checkout*,
   the deployed branch:

   ```bash
   git remote add origin git@github.com:you/example.git
   git fetch origin gh-pages
   ```

   This avoids a checkout of all files for nothing, which is a somewhat
   expensive Git operation depending on the number of files in the repository.
1. Build your static site into the repository (this example assumes a Jekyll
   site):

   ```bash
   cd /path/to/site
   bundle exec jekyll build --destination /path/to/example
   ```
1. Go back to the repository and create a local branch that points to the latest
   commit, but *without switching to the branch* to avoid a checkout:

   ```bash
   git branch --track gh-pages origin/gh-pages
   ```
1. *This is where the Git magic happens.* Change the `HEAD` to point to the new
   local branch, but do it with the [`symbolic-ref` Git plumbing
   command][git-symbolic-ref]:

   ```bash
   git symbolic-ref HEAD refs/heads/gh-pages
   ```

   This switches to the `gh-pages` branch which becomes the current branch, but
   *without touching either the working tree or the index* of the repository.
   This means that the index remains in the same state as the latest commit on
   `origin/gh-pages`, and the working tree contains your fresh static build with
   your latest changes.
1. Stage all additions, modifications and deletions:

   ```bash
   git add .
   ```

   Any file which was present in the previous version but is no longer present
   in the newest build of your static site will be automatically marked as
   deleted by Git.
1. Commit all changes:

   ```bash
   git commit -m "Deploy on $(date)"
   ```
1. Push the new build:

   ```bash
   git push origin gh-pages
   ```

You can say you used a [Git plumbing command][git-plumbing] at your next
meeting.

[git-plumbing]: https://git-scm.com/book/en/v2/Git-Internals-Plumbing-and-Porcelain#ch10-git-internals
[git-symbolic-ref]: https://git-scm.com/docs/git-symbolic-ref
[github-pages]: https://pages.github.com
[hugo]: https://gohugo.io
[jekyll]: https://jekyllrb.com
[static-site-generators]: https://jamstack.org/generators/
