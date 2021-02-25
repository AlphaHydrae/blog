---
layout: post
title: A JavaScript function that recursively resolves promises
date: '2021-02-25 17:24:43 +0100'
comments: true
today:
  type: wrote
categories: programming
tags: javascript async-await
---

Hello, World!

<!-- more -->

```js
async function resolve(value) {
  const resolved = await value;
  if (isPlainObject(resolved)) {
    const keys = Object.keys(resolved);
    const values = await Promise.all(Object.values(resolved).map(resolve));
    return zipObject(keys, values);
  } else if (isArray(resolved)) {
    return Promise.all(resolved.map(resolve));
  }

  return resolved;
};
```
