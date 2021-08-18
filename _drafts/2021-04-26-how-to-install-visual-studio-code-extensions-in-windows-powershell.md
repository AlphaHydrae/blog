---
layout: post
title: How to list and install Visual Studio Code extensions in PowerShell
date: '2021-04-26 15:51:00 +0200'
comments: true
today:
  type: learned
categories: programming
tags: vscode
---

Hello, World!

<!-- more -->

code --list-extensions > extensions.txt
code --list-extensions | Out-File -FilePath extensions.txt

for extension in $(cat extensions.txt); do code --install-extension $extension; done

ForEach ($ext in (Get-Content -Path extensions.txt)) { code --install-extension "$ext" }
