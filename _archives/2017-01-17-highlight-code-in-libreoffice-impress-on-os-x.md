---
layout: post
title: "Highlight code in LibreOffice Impress on OS X"
date: 2017-01-17 16:00
comments: true
permalink: /:year/:month/:title/
categories: programming
tags: syntax-highlighting libre-office os-x
versions:
  libre-office: 4.3.4.1
  python: 3.3.5
  os-x: 10.10.5 Yosemite
---

It's a pain to put code with proper syntax highlighting in slides, but it turns
out there's a solution for LibreOffice that does not involve taking screenshots,
copying-and-pasting rendered HTML, or manually coloring text.

This article describes how to install
[libreoffice-code-highlighter][libreoffice-code-highlighter], a syntax
highlighting Python macro for LibreOffice, on OS X (the original instructions
are for Linux). It uses [Pygments][pygments] to perform the syntax highlighting.

<!-- more -->

First, download the [Highlight.py][highlight-py] macro script and save it to
your LibreOffice's python scripts directory. The following commands will
accomplish this:

```bash
mkdir -p ~/Library/Application\ Support/LibreOffice/4/user/scripts/python
curl https://raw.githubusercontent.com/slgobinath/libreoffice-code-highlighter/master/Highlight.py > ~/Library/Application\ Support/LibreOffice/4/user/scripts/python/Highlight.py
```

(The `/4` part probably depends on your version of LibreOffice.)

Download the [Pygments source code][pygments-downloads] wherever you want, for
example to `~/Downloads/pygments-main`.

Go to that directory in a terminal, and install Pygments with LibreOffice's
bundled Python version:

```bash
cd ~/Downloads/pygments-main
/Applications/LibreOffice.app/Contents/MacOS/python \
  -E setup.py install
```

Now you can configure a keyboard shortcut to trigger the macro in LibreOffice:

* Go to **Tools** > **Customize** > **Keyboard**
* Select the **LibreOffice** option button (available in the top left corner)
* Select any desired shortcut
* Select **LibreOffice Macros/user/Highlight/highlight_source_code** in the
  Category and Function boxes
* Click the **Modify** button to set the shortcut

{% img /assets/contents/impress-highlight/shortcut.png %}

You're all set! Follow the [usage instructions][highlighter-usage] of
**libreoffice-code-highlighter** to highlight some code.

## Meta

[Version `f21631` of
libreoffice-code-highlighter](https://github.com/slgobinath/libreoffice-code-highlighter/blob/f216316783fa558ce0bd10da227a32500ca1a157/Highlight.py)
was used.



[libreoffice-code-highlighter]: https://github.com/slgobinath/libreoffice-code-highlighter
[highlight-py]: https://github.com/slgobinath/libreoffice-code-highlighter/blob/master/Highlight.py
[pygments]: http://pygments.org
[pygments-downloads]: https://bitbucket.org/birkenfeld/pygments-main/downloads
[highlighter-usage]: https://github.com/slgobinath/libreoffice-code-highlighter#usage
