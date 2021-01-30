---
layout: post
title: "Symmetric encryption with GnuPG 2"
date: 2012-09-19 09:36
comments: true
categories: [gnupg, encryption]
permalink: /:year/:month/:title/
---

[{% img right /assets/contents/gnupg/logo.png 200 %}](http://www.gnupg.org)

I use these commands to symmetrically encrypt files with GnuPG 2. Sometimes you
just need to get away from all this private/public key business.

Install **gnupg2** with your favorite package manager, then type the following
commands. It will prompt for the encryption password:

{% highlight bash %}
# encrypt file.txt to file.txt.gpg
gpg2 -c -a --force-mdc --batch -o file.txt.gpg file.txt

# decrypt file.txt.gpg to file.txt
gpg2 -d --batch -o file.txt file.txt.gpg
{% endhighlight %}

If you want to get the password from a file, use these:

{% highlight bash %}
# encrypt file.txt to file.txt.gpg
gpg2 -c -a --force-mdc --batch --passphrase-file passphrase.txt -o file.txt.gpg file.txt

# decrypt file.txt.gpg to file.txt
gpg2 -d --batch --passphrase-file passphrase.txt -o file.txt file.txt.gpg
{% endhighlight %}

May your files be secure.
