---
layout: post
title: "Pimp your Vim"
date: 2012-09-28 09:46
comments: false
categories: 
---

In the good ol' days I used Eclipse, NetBeans, Dreamweaver. Then I switched to TextMate when I started doing Ruby. Now I use Vim for all my Ruby/Javascript development. At this point in my backwards journey, I would like to document how you can increase the awesomeness of Vim using a few well-chosen plugins.

First things first: use pathogen.vim! Pathogen allows you to install each Vim plugin in its own separate directory under .vim/bundle. It makes your life much less painful.

{% codeblock lang:bash %}
# Installation procedure from https://github.com/tpope/vim-pathogen
mkdir -p ~/.vim/autoload ~/.vim/bundle; \
curl -Sso ~/.vim/autoload/pathogen.vim https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim
 
# Add this to your ~/.vimrc
call pathogen#infect()
{% endcodeblock %}

## NERD tree

This is a filesystem tree that you can display as a sidebar. You can navigate it with your keyboard and/or mouse. Open it up with :NERDTree.

{% codeblock lang:bash %}
# Install with pathogen
cd ~/.vim/bundle
git clone https://github.com/scrooloose/nerdtree
{% endcodeblock %}

{% img center /images/contents/vim/nerdtree.png %}

## SuperTab

Allows you to use the Tab key for auto-completion.

{% codeblock lang:bash %}
# Install with pathogen
cd ~/.vim/bundle
git clone https://github.com/ervandew/supertab
{% endcodeblock %}

{% img center /images/contents/vim/supertab.png %}

## rails.vim

Ruby on Rails power tools. It adds syntax highlighting for methods like has_and_belongs_to_many, allows you to jump between related files (model, controller, helper, migration, etc), and more.

{% codeblock lang:bash %}
# Install with pathogen
cd ~/.vim/bundle
git clone git://github.com/tpope/vim-rails.git
{% endcodeblock %}

## Command-T

"Go to file" smart plugin. It does pretty awesome things like find `/app/controllers/home_controller.rb` just by typing `ach`. It's a bit trickier to install because it has a C Ruby extension for speed.

You must have Vim compiled with Ruby support. To check this, type `vim --version`. If `+ruby` appears in the version information then you have Ruby support. To compile Vim with Ruby support on OS X with MacPorts, install it with `sudo port install vim +ruby`.

{% codeblock lang:bash %}
# Install with pathogen
cd ~/.vim/bundle
git clone https://github.com/wincent/Command-T
 
# Build C extension
# WARNING: You must do this with the same Ruby that Vim was
#          compiled with. In my case, I have RVM and installed
#          Vim+ruby with MacPorts, so I had to run "rvm use system"
#          to switch to the MacPorts Ruby.
cd ~/.vim/bundle/command-t/ruby/command-t
ruby extconf.rb
make
{% endcodeblock %}

Once installed, you can bring up the Command-T interface with `:CommandT` or `<Leader>t`. The leader character is your personal modifier key (backslash by default). I have configured it to be a comma, so I bring up Command-T by typing `,t`.

{% codeblock %}
# Location: ~/.vimrc
 
# Use comma as the leader character
let mapleader = ","
{% endcodeblock %}

{% img center /images/contents/vim/commandt.png %}

## fugitive.vim

Git wrapper to call Git commands from Vim. Allows you to manipulate the index, move files with open buffers, and much more. Watch this screencast for an introduction.

{% codeblock lang:bash %}
# Install with pathogen
cd ~/.vim/bundle
git clone https://github.com/tpope/vim-fugitive
{% endcodeblock %}

Let the tuning begin.
