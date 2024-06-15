---
layout: post
title: How to check which Git branches contain a commit
date: '2021-02-14 15:42:39 +0100'
comments: true
today:
  type: learned
categories: tooling
tags: cli
versions:
  git: 2.30.1
---

The [`--contains` option of the `git branch` command][git-branch-contains] will
list branches which contain the specified commit, in the same format as when
running `git branch` or `git branch --list`:

```bash
$> git branch --contains aa82193
* some-branch
  master
```

This output indicates that both the `some-branch` branch and the `master` branch
contain commit `aa82193` (and that `some-branch` is the current branch).

> There is an inverse option, [the `--no-contains`
> option][git-branch-no-contains], which will only list branches that don't
> contain the specified commit.

[git-branch-contains]: https://git-scm.com/docs/git-branch#Documentation/git-branch.txt---containsltcommitgt
[git-branch-no-contains]: https://git-scm.com/docs/git-branch#Documentation/git-branch.txt---no-containsltcommitgt
