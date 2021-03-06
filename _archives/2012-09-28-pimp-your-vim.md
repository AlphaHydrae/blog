---
layout: post
title: "Pimp your Vim"
date: 2012-09-28 09:46
comments: true
permalink: /:year/:month/:title/
categories: tooling
tags: tools
versions:
  vim: 7.x
---

[{% img right /assets/contents/vim/logo.gif %}](http://www.vim.org)

In the good ol' days I used Eclipse, NetBeans, Dreamweaver. Then I switched to
TextMate when I started doing Ruby. Now I use Vim for all my Ruby/Javascript
development. At this point in my backwards journey through time, I would like to
document how you can increase the awesomeness of Vim using a few well-chosen
plugins.

<!--more-->

First things first: **use [pathogen.vim][vim-pathogen]**. Pathogen allows you to
install each Vim plugin in its own separate directory under `.vim/bundle`. It
makes your life much less painful.

```bash
# Installation procedure from
# https://github.com/tpope/vim-pathogen:
mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -Sso ~/.vim/autoload/pathogen.vim \
  https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim

# Add this to your "~/.vimrc" file:
call pathogen#infect()
```

## [NERD tree](https://github.com/scrooloose/nerdtree)

This is a filesystem tree that you can display as a sidebar. You can navigate it
with your keyboard and/or mouse. Open it up with `:NERDTree`.

```bash
# Install with pathogen:
cd ~/.vim/bundle
git clone https://github.com/scrooloose/nerdtree
```

{% img center /assets/contents/vim/nerdtree.png %}

## [SuperTab](https://github.com/ervandew/supertab)

Allows you to use the Tab key for auto-completion.

```bash
# Install with pathogen:
cd ~/.vim/bundle
git clone https://github.com/ervandew/supertab
```

{% img center /assets/contents/vim/supertab.png %}

## [rails.vim](https://github.com/tpope/vim-rails)

Ruby on Rails power tools. It adds syntax highlighting for methods like
`has_and_belongs_to_many`, allows you to jump between related files (model,
controller, helper, migration, etc), and more.

```bash
# Install with pathogen:
cd ~/.vim/bundle
git clone git://github.com/tpope/vim-rails.git
```

## [Command-T](https://github.com/wincent/Command-T)

"Go to file" smart plugin. It does pretty awesome things like find
`/app/controllers/home_controller.rb` just by typing `ach`. It's a bit trickier
to install because it has a C Ruby extension for speed.

You must have Vim compiled with Ruby support. To check this, type `vim
--version`. If `+ruby` appears in the version information then you have Ruby
support. To compile Vim with Ruby support on OS X with MacPorts, install it with
`sudo port install vim +ruby`.

```bash
# Install with pathogen
cd ~/.vim/bundle
git clone https://github.com/wincent/Command-T

# Build C extension
# WARNING: You must do this with the same Ruby that Vim
#          was compiled with. In my case, I have RVM and
#          installed Vim+ruby with MacPorts, so I had to
#          run "rvm use system" to switch to the
#          MacPorts Ruby.
cd ~/.vim/bundle/command-t/ruby/command-t
ruby extconf.rb
make
```

Once installed, you can bring up the Command-T interface with `:CommandT` or
`<Leader>t`. The leader character is your personal modifier key (backslash by
default). I have configured it to be a comma, so I bring up Command-T by typing
`,t`.

```viml
# File: ~/.vimrc

# Use comma as the leader character
let mapleader = ","
```

{% img center /assets/contents/vim/commandt.png %}

## [fugitive.vim](https://github.com/tpope/vim-fugitive)

Git wrapper to call Git commands from Vim. Allows you to manipulate the index,
move files with open buffers, and much more. Watch the following screencast for
an introduction: [*Fugitive.vim - a complement to command line
git*][vim-fugitive-screencast].

```bash
# Install with pathogen
cd ~/.vim/bundle
git clone https://github.com/tpope/vim-fugitive
```

Let the tuning begin.

[vim-pathogen]: https://github.com/tpope/vim-pathogen
[vim-fugitive-screencast]: http://vimcasts.org/episodes/fugitive-vim---a-complement-to-command-line-git/
