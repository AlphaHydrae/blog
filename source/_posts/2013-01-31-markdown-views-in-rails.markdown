---
layout: post
title: "Markdown views with syntax highlighting in Rails"
date: 2013-01-31 17:46
comments: true
categories: [markdown, highlight, rails, redcarpet, pygments]
---

Today I had to add technical documentation pages to a Rails app. I chose to write those in [Markdown](http://daringfireball.net/projects/markdown/) as that's what I'm used to and it's a widely-used format. This post describes how to render Markdown views in a Rails application with [Pygments](http://pygments.org) for code syntax highlighting.

<!-- more -->

The [markdown-rails](https://github.com/joliss/markdown-rails) gem enables `.html.md` views. [Redcarpet](https://github.com/vmg/redcarpet) is a better parser which you'll want to use to have features like [GitHub Flavored Markdown](http://github.github.com/github-flavored-markdown/). Finally, [pyments.rb](https://github.com/tmm1/pygments.rb) will handle the syntax highlighting.

Add those gems to your `Gemfile` and run `bundle install`.

{% codeblock lang:ruby Gemfile %}
gem "markdown-rails"
gem "redcarpet"
gem "pygments.rb"
{% endcodeblock %}

To configure the parser and enable syntax highlighting, you can add this initializer.

{% codeblock lang:ruby config/initializers/markdown.rb %}
# Override the default renderer to add syntax highlighting with Pygments.
class PygmentsHTML < Redcarpet::Render::HTML

  def block_code code, language
    Pygments.highlight code, :lexer => language
  end
end

MarkdownRails.configure do |config|

  # See https://github.com/vmg/redcarpet for options.
  markdown = Redcarpet::Markdown.new(PygmentsHTML,
    :tables => true,
    :fenced_code_blocks => true,
    :autolink => true
  )

  config.render do |markdown_source|
    markdown.render markdown_source
  end
end
{% endcodeblock %}

Note that you must have Pygments' `pygmentize` command installed and in your path. You may install it on most platforms with `easy_install`:

{% codeblock lang:bash %}
easy_install Pygments
{% endcodeblock %}

Well, that was pretty painless.
