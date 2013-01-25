---
layout: post
title: "Symmetric encryption with GnuPG 2"
date: 2012-09-19 09:36
comments: false
categories: [gnupg, encryption]
---

[{% img right /images/contents/gnupg/logo.png 200 %}](http://www.gnupg.org)

Sometimes you get sick of all this private/public key business and you just want to symmetrically encrypt some files. It ought to be simple!

I do that with GnuPG 2. Install gnupg2 with your favorite package manager, then use the following commands. These will prompt for the encryption password:

{% codeblock lang:bash %}
# encrypt file.txt to file.txt.gpg
gpg2 -c -a --force-mdc --batch -o file.txt.gpg file.txt
 
# decrypt file.txt.gpg to file.txt
gpg2 -d --batch -o file.txt file.txt.gpg
{% endcodeblock %}

If you want to get the password from a file, use these:

{% codeblock lang:bash %}
# encrypt file.txt to file.txt.gpg
gpg2 -c -a --force-mdc --batch --passphrase-file passphrase.txt -o file.txt.gpg file.txt
 
# decrypt file.txt.gpg to file.txt
gpg2 -d --batch --passphrase-file passphrase.txt -o file.txt file.txt.gpg
{% endcodeblock %}

May your files be secure.
