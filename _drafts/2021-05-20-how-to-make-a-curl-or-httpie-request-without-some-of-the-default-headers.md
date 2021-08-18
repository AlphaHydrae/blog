---
layout: post
title: How to make a curl or HTTPie request without some of the default headers
date: '2021-05-20 17:36:01 +0200'
comments: true
today:
  type: learned
categories: programming
tags: curl httpie
---

Hello, World!

<!-- more -->

```
curl -vvv -H "Host:" http://localhost:3000
```

```
http :3000 "Host;"
GET / HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Host:
User-Agent: HTTPie/2.4.0

HTTP/1.1 400 Bad Request
Connection: keep-alive
Date: Thu, 20 May 2021 15:34:49 GMT
Keep-Alive: timeout=5
Transfer-Encoding: chunked
```
