---
layout: post
title: "Summoning is complete"
date: 2012-08-15 09:14
comments: false
categories: [shell, workflow]
---

I'm a lazy developer and an even lazier sysadmin. This is my history search function.

{% codeblock lang:bash %}
summon () {
  if (( $# >= 1 )); then
    history 0|grep -e "$*"
  else
    history 0
  fi
}
 
alias smn="summon"
{% endcodeblock %}

`smn` gets you the whole history; `smn curl` finds all curl commands.
