---
layout: post
title: How to write a plain Node.js server to redirect HTTP to HTTPS
date: '2021-05-19 23:06:18 +0200'
comments: true
today:
  type: learned
categories: programming
tags: node
---

Hello, World!

<!-- more -->

```js
const http = require('http');

http.createServer((req, res) => {
  res.writeHead(301, { "Location": "https://" + req.headers['host'] + req.url });
  res.end();
}).listen(4000);
```
