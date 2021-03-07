---
layout: post
title: asdf, one version manager to rule them all
date: '2021-03-06 21:32:17 +0100'
comments: true
today:
  type: found
  past: true
categories: tooling
tags: cli asdf
versions:
  asdf: 0.8.0
  asdf-nodejs: 5a46614
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

When I started playing with Elixir, I discovered [asdf][asdf], a version manager
capable of installing and managing multiple versions of both [Elixir][elixir]
and [Erlang][erlang], but also Ruby and Node.js which I am still using
regularly. Not only that, it's a plugin-based version manager with plugins for
practically every programming language.

## I need to get me some of that!

You can [install asdf][asdf-install] with Aptitude on Linux or with
[Homebrew][brew] on macOS:

```bash
# Install dependencies
$> brew install coreutils curl git
# Install asdf itself
$> brew install asdf
```

> On Windows, it should work in the [Windows Subsystem for Linux (WSL)][wsl].

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

> A plugin might require additional setup. For example, this plugin requires you
> to [import the Node.js release team's OpenPGP keys][asdf-nodejs-install] to
> ensure the authenticity of downloaded Node.js releases.

Once installed, the plugin allows you to list the available versions for the
language:

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

You can install whatever versions you want:

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

You can put a similar file in one of your projects if it uses a different
version than the others:

```bash
$> node --version
v14.16.0

$> echo "nodejs 15.11.0" > ~/path/to/project/.tool-versions
$> cd ~/path/to/project
$> node --version
v15.11.0
```

> As another example, you can check [the `.tool-versions` file in this blog's
> repository](https://github.com/AlphaHydrae/blog/blob/main/.tool-versions).

You can also use an environment variable to set the current version. The name of
the variable depends on which plugin you're using. For example, the variable for
the Node.js plugin is `ASDF_NODEJS_VERSION`:

```bash
$> node --version
v14.16.0

$> ASDF_NODEJS_VERSION=15.11.0 node --version
v15.11.0
```

## What sorcery is this?

If you check your PATH, you will notice that the `~/.asdf/shims` directory has
been added to it:

```bash
$> echo $PATH
/Users/alice/.asdf/shims:...
```

When you install a Node.js version with asdf, it will put a `node` executable
for Node.js in [the shims directory][asdf-shims]. This executable isn't actually
Node.js. You can see this by displaying its contents:

```bash
$> cat ~/.asdf/shims/node
exec /usr/local/bin/asdf exec "node" "$@"
```

The shim is here to "intercept" the execution of Node.js (since the shims
directory should be the first thing in your [PATH][path]), and to instead call
asdf with the language used and any additional arguments. asdf will select the
correct version of Node.js to run depending on your various `.tool-versions`
file and the `ASDF_NODEJS_VERSION` environment variable, and call the
corresponding Node.js executable somewhere in the `~/.asdf/installs` directory
(for example, the executable for version 14.16.0 of Node.js is at
`~/.asdf/installs/nodejs/14.16.0/bin/node`).

> Other related commands such as `npm` and any global Node.js package you might
> install will also have corresponding scripts in the shims directory.

Shims is how many programming language version managers work. The previously
mentionned rbenv and nodenv [work the same way][rbenv-shims].

This mechanism makes it easy to use asdf-installed versions of programming
languages from a script. Simply put the shims directory in the PATH and set the
correct environment variable to the desired version.

Go forth and install all the versions.

[asdf]: https://asdf-vm.com
[asdf-install]: https://asdf-vm.com/#/core-manage-asdf
[asdf-nodejs]: https://github.com/asdf-vm/asdf-nodejs
[asdf-nodejs-install]: https://github.com/asdf-vm/asdf-nodejs#install
[asdf-plugins]: https://asdf-vm.com/#/plugins-all?id=plugin-list
[asdf-shims]: https://asdf-vm.com/#/core-manage-versions?id=shims
[brew]: https://brew.sh
[elixir]: https://elixir-lang.org
[erlang]: https://www.erlang.org
[node]: https://nodejs.org
[nodenv]: https://github.com/nodenv/nodenv
[nvm]: https://github.com/nvm-sh/nvm
[path]: https://en.wikipedia.org/wiki/PATH_(variable)
[rails]: https://rubyonrails.org
[rbenv]: https://github.com/rbenv/rbenv
[rbenv-shims]: https://github.com/rbenv/rbenv#understanding-shims
[ruby]: https://www.ruby-lang.org
[rvm]: https://rvm.io
[wsl]: https://docs.microsoft.com/en-us/windows/wsl/about
