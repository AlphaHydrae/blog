---
layout: post
title: "Markdown views with syntax highlighting in Rails"
date: 2013-01-31 17:46
comments: true
permalink: /:year/:month/:title/
categories: programming
tags: ruby ruby-on-rails markdown syntax-highlighting
versions:
  ruby: 1.9.3
  ruby-on-rails: 3.x
  markdown: redcarpet 2.x
  pygments.rb: < 0.5.0
---

Today I had to add technical documentation pages to a Rails app. I chose to
write those in [Markdown][markdown] as that's what I'm used to and it's a
widely-used format. This post describes how to render Markdown views in a [Ruby
on Rails][ruby-on-rails] application with [Pygments][pygments] for code syntax
highlighting.

<!-- more -->

The [markdown-rails][markdown-rails] gem enables `.html.md` views.
[Redcarpet][redcarpet] is a better parser which you'll want to use to have
features like [GitHub Flavored Markdown][gfm]. Finally,
[pyments.rb][pygments.rb] will handle the syntax highlighting.

Add those gems to your `Gemfile` and run `bundle install`:

```ruby
gem "markdown-rails"
gem "redcarpet"
gem "pygments.rb"
```

To configure the parser and enable syntax highlighting, you can add this
initializer:

```ruby
# File: config/initializers/markdown.rb

# Override the default renderer to add syntax
# highlighting with Pygments.
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
```

Note that you must have Pygments' `pygmentize` command installed and in your
path. You may install it on most platforms with `easy_install`:

```bash
easy_install Pygments
```

Well, that was pretty painless.

[gfm]: https://github.github.com/gfm/
[markdown]: http://daringfireball.net/projects/markdown/
[markdown-rails]: https://github.com/joliss/markdown-rails
[pygments]: http://pygments.org
[pygments.rb]: https://github.com/tmm1/pygments.rb
[redcarpet]: https://github.com/vmg/redcarpet
[ruby-on-rails]: https://rubyonrails.org
