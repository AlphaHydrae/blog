---
layout: post
title: asdf, one version manager to rule them all
date: '2021-03-06 21:32:17 +0100'
comments: true
today:
  type: found
  past: true
categories: tooling
tags: cli
versions:
  asdf: 0.8.0
---

[asdf][asdf] is an extendable version manager with support for [Ruby][ruby],
[Node.js][node], [Elixir][elixir], [Erlang][erlang], [and more][asdf-plugins].

When you regularly work on multiple projects using the same programming
language, Node.js for example, you might need different versions of the language
for different projects. One project might require version 14, currently the
latest stable version, while another project might still be using version 10.
It's a pain to install all these versions yourself and manage your [PATH][path],
especially if you work with multiple programming languages on a daily basis.

<!-- more -->

[rvm][rvm] was the first programming language version manager I used back when I
was doing a lot of [Ruby on Rails][rails]. Then I switched to [rbenv][rbenv]
because it seemed simpler and used less dark shell magic. [nvm][nvm] and
[nodenv][nodenv] are similar tools for Node.js. I have also used the latter.

When I started playing with [Elixir][elixir], I discovered [asdf][asdf], a
version manager capable of installing and managing multiple versions of both
Elixir and [Erlang][erlang]. Not only that, it's a plugin-based version manager
with plugins for practically every programming language.

## I need to get me some of that!

You can [install asdf][asdf-install] with Aptitude on Linux or with
[Homebrew][brew] on macOS:

```bash
# Install dependencies
$> brew install coreutils curl git
# Install asdf itself
$> brew install asdf
```

You also need to add it to your shell by adding this line to your shell
configuration file, for example `.zshrc` or `.bash_profile`:

```bash
. $(brew --prefix asdf)/asdf.sh
```

Restart your shell for this change to take effect. You can now use asdf. The
first thing you need to do is install a plugin for your favorite programming
language, for example [the Node.js plugin][asdf-nodejs]:

```bash
$> asdf plugin add nodejs
```

The plugin allows you to list the available versions for the language:

```bash
$> asdf list all nodejs
...
14.0.0
...
14.16.0
15.0.0
...
15.11.0
```

Now you can install whatever versions you want:

```
$> asdf install nodejs 14.16.0
$> asdf install nodejs 15.11.0
```

You can change the version of a language used in the current shell like this:

```bash
$> asdf shell nodejs 15.11.0
$> node --version
v15.11.0

$> asdf shell nodejs 14.16.0
$> node --version
v14.16.0
```

This will only last until you close that shell. But you can also set the default
global version for your user so that it persists for any new shell:

```bash
$> asdf global nodejs 14.16.0
```

This actually just puts a line in your `~/.tool-versions` file:

```bash
$> cat ~/.tool-versions
nodejs 14.16.0
```

## What sorcery is this?

If you check your PATH, you
will notice that the `~/.asdf/shims` directory has been added to it. Shims is
how most programming language version managers work: asdf will put a `node` executable
in there for Node.js, for example. This executable isn't actually Node.js

```bash
$> cat ~/.asdf/shims/node
exec /usr/local/bin/asdf exec "node" "$@"
```

```bash
$> echo $PATH
/Users/alice/.asdf/shims:...
```

[asdf]: https://asdf-vm.com
[asdf-install]: https://asdf-vm.com/#/core-manage-asdf
[asdf-nodejs]: https://github.com/asdf-vm/asdf-nodejs
[asdf-plugins]: https://asdf-vm.com/#/plugins-all?id=plugin-list
[brew]: https://brew.sh
[elixir]: https://elixir-lang.org
[erlang]: https://www.erlang.org
[node]: https://nodejs.org
[nodenv]: https://github.com/nodenv/nodenv
[nvm]: https://github.com/nvm-sh/nvm
[path]: https://en.wikipedia.org/wiki/PATH_(variable)
[rails]: https://rubyonrails.org
[rbenv]: https://github.com/rbenv/rbenv
[ruby]: https://www.ruby-lang.org
[rvm]: https://rvm.io
