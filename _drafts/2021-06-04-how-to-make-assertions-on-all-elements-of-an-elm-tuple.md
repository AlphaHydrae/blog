---
layout: post
title: How to make assertions on all elements of an Elm tuple
date: '2021-06-04 13:25:36 +0200'
comments: true
today:
  type: learned
categories: programming
tags: elm
---

Hello, World!

<!-- more -->

```elm
update msg model
    |> Expect.all
        [ Tuple.first >> Expect.equal 2
        , Tuple.second >> Expect.equal 3
        ]
```
