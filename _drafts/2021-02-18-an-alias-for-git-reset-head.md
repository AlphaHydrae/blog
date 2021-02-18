---
layout: post
title: An alias for git reset HEAD
date: '2021-02-18 19:56:22 +0100'
comments: true
today:
  type: wrote
categories: tooling
versions:
  git: 2.30.1
---

I'm too lazy to type `git reset HEAD <file>`. There's too many characters.

<!-- more -->

```bash
$> echo world > hello.txt

$> git add hello.txt

$> git status
On branch master
Your branch is up to date with 'origin/master'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	modified:   hello.txt
```
