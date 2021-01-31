---
layout: post
title: Tailwind CSS, a cool utility-first CSS framework
date: '2021-01-24 20:45:37 +0100'
comments: true
today:
  type: found
categories: programming
tags: css
versions:
  tailwind-css: 2.x
  post-css: 8.x
---

[Tailwind CSS][tailwind-css] is a utility-first CSS framework packed with classes
like `flex`, `pt-4`, `text-center` and `rotate-90` that can be composed to build
any design, directly in your markup.

I've been using [Bootstrap][bootstrap] for a while, at least since version 2 was
released in 2012. I still use it. It has its faults, one of them being that when
you use Bootstrap without spending some time to customize it, your website kind
of looks the same as all other Bootstrap websites.

Tailwind CSS is lower-level than Bootstrap. It has [primitive
utilities][tailwind-css-utility-first] rather than UI components. Think grids,
colors, margins, not buttons and cards. I think it would be more accurate to
call it a CSS library rather than a CSS framework, in the same way that jQuery
is a library and React or Vue are frameworks. There is a higher level [Tailwind
UI][tailwind-ui] library which seems to be more like a framework.

The theme of this blog is **entirely styled with Tailwind CSS, with not one line
of custom CSS** (with the exception of the CSS used for syntax highlighting of
code).

I'm not a designer, and I'm not winning any design awards any time soon, but I
think this theme looks okay and it's pretty cool I was able to create it in a
few days with these utilities when I'm definitely not a CSS pro.

## Building components from primitive utilities

Traditionally, whenever you need to style something on the web, you write CSS.
With Tailwind, you style elements by [applying pre-existing classes directly in
your HTML][tailwind-css-utility-first]:

```html
<div class="flex items-center p-6 max-w-sm mx-auto bg-white">
  <div class="flex-shrink-0">
    <img class="h-12 w-12"
         src="/img/logo.svg" alt="ChitChat Logo" />
  </div>
  <div>
    <div class="text-xl font-medium">ChitChat</div>
    <p class="text-gray-500">You have a new message!</p>
  </div>
</div>
```

Take a look at [the Liquid template for the layout of this
page](https://github.com/AlphaHydrae/blog/blob/92e6262ba1098df47fe25b3a137efda1d9e8fce4/_layouts/post.html#L6-L71).
All of the classes you see in the various `class` attributes are Tailwind
utilities.

## Mobile-first, responsive design

Tailwind CSS is designed to [build adaptive user
interfaces][tailwind-css-responsive-design].

Like Bootstrap, Tailwind encourages a [mobile-first][tailwind-css-mobile-first]
design. What this means is that unprefixed utilities (like `uppercase`) take
effect on all screen sizes, while prefixed utilities (like `md:uppercase`) only
take effect at the specified breakpoint and above.

```html
<!--
  Width of 16 by default,
  32 on medium screens,
  and 48 on large screens
-->
<img class="w-16 md:w-32 lg:w-48" src="..." />
```

## Adding base styles

You can [define base styles][tailwind-css-adding-base-styles] to avoid repeating
yourself. This helps keep your design [DRY][dry].

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  h1 {
    @apply text-2xl;
  }
  h2 {
    @apply text-xl;
  }
}
```

Take a look at [the stylesheet for this
blog](https://github.com/AlphaHydrae/blog/blob/92e6262ba1098df47fe25b3a137efda1d9e8fce4/assets/css/style.css#L8-L141).
Note the absence of any custom CSS (except the syntax highlighting CSS): all
styles are derived from Tailwind's primitive utilities.

## Some more information

While Bootstrap is based on [Sass][sass], Tailwind CSS is [installed as a
PostCSS plugin][tailwind-css-post-css]. [PostCSS][post-css] is a tool for
transforming CSS with JavaScript. You can combine Tailwind with other PostCSS
plugins like [the PostCSS autoprefixer plugin][post-css-autoprefixer].

This blog is made with [Jekyll][jekyll]. Integrating Tailwind CSS is easy with
the [Jekyll PostCSS plugin][jekyll-post-css]. It takes one line, as you can see
in [this blog's PostCSS configuration
file](https://github.com/AlphaHydrae/blog/blob/92e6262ba1098df47fe25b3a137efda1d9e8fce4/postcss.config.js#L6).

[bootstrap]: https://getbootstrap.com
[dry]: https://en.wikipedia.org/wiki/Don%27t_repeat_yourself
[jekyll]: https://jekyllrb.com
[jekyll-post-css]: https://github.com/mhanberg/jekyll-postcss
[post-css]: https://postcss.org
[post-css-autoprefixer]: https://github.com/postcss/autoprefixer
[sass]: https://sass-lang.com
[tailwind-css]: https://tailwindcss.com
[tailwind-css-adding-base-styles]: https://tailwindcss.com/docs/adding-base-styles
[tailwind-css-mobile-first]: https://tailwindcss.com/docs/responsive-design#mobile-first
[tailwind-css-post-css]: https://tailwindcss.com/docs/installation#installing-tailwind-css-as-a-post-css-plugin
[tailwind-css-responsive-design]: https://tailwindcss.com/docs/responsive-design
[tailwind-css-utility-first]: https://tailwindcss.com/docs/utility-first
[tailwind-ui]: https://tailwindui.com
