---
layout: post
title: "Summoning is complete"
date: 2012-08-15 09:14
comments: true
permalink: /:year/:month/:title/
categories: tooling
tags: cli shell
---

I'm a lazy developer and an even lazier sysadmin. This is my history search
function.

```bash
summon () {
  if (( $# >= 1 )); then
    history 0|grep -e "$*"
  else
    history 0
  fi
}

alias smn="summon"
```

`smn` gets you the whole history; `smn curl` finds all curl commands.
