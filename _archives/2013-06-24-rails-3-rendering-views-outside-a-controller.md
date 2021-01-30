---
layout: post
title: "Rails 3: rendering views outside a controller"
date: 2013-06-24 09:24
comments: true
permalink: /:year/:month/:title/
categories: programming
tags: []
versions:
  ruby: 2.x
  ruby-on-rails: 3.x
---

I discovered recently that [Ruby on Rails][ruby-on-rails] 3's action views
really don't like it when you try to render them outside a controller. This was
a problem, as I wanted to render a view in a [Resque][resque] background task
for caching.

You have to jump through a few hoops to make it work. The trick is to create a
subclass of `ActionView::Base` and mix in a few things it's missing:

```ruby
module Renderer

  # Renders a view.
  def self.render options = {}

    # Pass a hash of local variables as :assigns.
    assigns = options.delete(:assigns) || {}

    # Create a view.
    view = view_class.new(
      ActionController::Base.view_paths, assigns
    )

    # Mix in other helpers you need.
    view.extend ApplicationHelper
    view.extend CustomHelper

    # Render.
    view.render options
  end

  # Creates a subclass of ActionView::Base with route
  # helpers mixed in.
  def self.view_class
    @view_class ||= Class.new ActionView::Base do
      include Rails.application.routes.url_helpers
    end
  end
end
```

You can then use it from wherever:

```ruby
Renderer.render(
  template: 'users/show',
  assigns: { user: @logged_user }
)
```

That's it. Not quite clean but at least it's short.

## Meta

* [Rails, How to render a view/partial in a model](http://stackoverflow.com/questions/6318959/rails-how-to-render-a-view-partial-in-a-model)
* [Render views and partials outside controllers in Rails 3](http://www.amberbit.com/blog/render-views-and-partials-outside-controllers-in-rails-3)
* [Render from model in Rails 3](https://gist.github.com/aliang/1022384)

[resque]: https://github.com/resque/resque
[ruby-on-rails]: https://rubyonrails.org
