---
layout: post
title: "REST &amp; Hypermedia APIs"
date: 2013-06-29 20:44
comments: true
categories: [api,http,hypermedia,patterns,rest]
---

{% img right /images/contents/hypermedia/wat.png 350 %}

Everybody writes REST APIs today.
Everybody knows [REST](http://en.wikipedia.org/wiki/Representational_state_transfer)
is more generic, scalable and extensible than SOAP. Or do they?

Like many I started writing REST APIs [the Rails way](http://guides.rubyonrails.org/routing.html#resource-routing-the-rails-default)
because Rails provides everything you need to quickly write a beautiful REST API out of the box.
Or so I thought.

After reading many articles and many more comments,
I now understand that most so-called REST APIs today are not actually RESTful according to how it was originally defined.
Many proponents of "true REST APIs" now seem to prefer talking about **Hypermedia APIs** which is a more practical description of what they are.
You'll also hear about the [**HATEOAS**](http://en.wikipedia.org/wiki/HATEOAS) principle, meaning **Hypermedia As The Engine Of Application State**, one of the constraints of the REST architecture.

Now I don't have a doctorate in computer science;
I'm just a lowly software engineer trying to code some APIs.
This post reflects my (condensed) understanding of how REST/Hypermedia APIs should work according to the specifications.

Note that many people disagree that this is how it should be done.
If you're interested in knowing more, I've listed the articles I found most useful to understand the subject at the bottom of this post.
The comments sections of these articles are particularly interesting as they contain descriptions of actual problems, possible solutions, and some thoughtful criticism.

1. [REST: The Rails Way](#rest-rails)
2. [Hypermedia APIs](#hypermedia-apis)
3. [Media Types](#media-types)
    * [HAL+JSON](#hal-json)
    * [Custom Media Types](#custom-media-types)

<a name="rest-rails"></a>
## REST: The Rails Way

This is the way most "REST APIs" I've seen work.

* A RESTful API consists of **resources** (that map directly or indirectly to your domain objects).
* Each resource or collection of resources has a **documented, unique URI**.
* These resources can be manipulated using **HTTP verbs** such as GET, POST, PUT, DELETE.
* Each resource can have many representations; a representation is selected through **content negotiation** with the Accept header (e.g. `application/json`, `application/xml`) or a suffix (e.g. `person.json`, `person.xml`).

In a nutshell, we're exposing domain objects through HTTP with CRUD operations and other custom operations, in some generic format like JSON.

{% img left /images/contents/hypermedia/stop.png 60 %}

This is the point where you may want to stop reading if you don't want this conception of a REST API to be eviscerated and transmogrified into a completely different animal.

<a name="hypermedia-apis"></a>
## Hypermedia APIs

Shockingly, this is not what a true RESTful API is supposed to be. At all. *Was I lied to?*

["REST APIs must be hyperlink-driven"](http://roy.gbiv.com/untangled/2008/rest-apis-must-be-hypertext-driven) wrote Dr. Fielding in a rant against RPC blasphemers.
What does he mean by that?
And what's up with this hyper stuff about hyperlinks and hypermedia anyway?
Why should I go through all this trouble anyway?

One word: the **Web.**

When you want to browse a website, there are basically two things you need to know about: the root URL, and that you can follow links to new information.
This is the simple but powerful concept of hyperlinks that has made the web so successful.

From a technical point of view, the client is getting a representation of a resource in the `text/html` media type; this media type defines the behavior of links.
The knowledge of the root URL and of the media type is sufficient to drive the interaction.
Even if the other URLs change, they can be reached again from the root URL through links.

Hypermedia APIs are based on the same principle.

{% blockquote Roy T. Fielding, REST APIs must be hypertext-driven %}
A REST API should be entered with no prior knowledge beyond the initial URI (bookmark) and set of standardized media types that are appropriate for the intended audience (i.e., expected to be understood by any client that might use the API).
{% endblockquote %}

Contrary to the previous notion of REST, there should be:

* No fixed URLs.
* No fixed resource names.
* No fixed hierarchies.

When designing an API, what you should spend time on are the **media types** used for representing resources.
These media types define relations to other resources through **hyperlinks**;
they drive the application state, hence *Hypermedia As The Engine Of Application State.*

<a name="media-types"></a>
## Media Types

*So what is this *media type* of which you speak?*

Surely we're going to use JSON for our API... right?
Almost. The problem is that `application/json` is not a *hypermedia* because it's not aware of hyperlinks.
There's nothing in the specification that tells a client that this `link` property you're using is actually a link.
It's not impossible to just use `application/json`, but there are benefits to using hyperlink-aware media types.

I'm not an expert (yet), but I'll outline the two solutions I've most seen talked about: HAL+JSON or custom media types.

<a name="hal-json"></a>
### HAL+JSON

HAL+JSON is a JSON media type for representing resources and their relations with hyperlinks.
This is an example document representing a list of orders:

```json
{
  "currentlyProcessing": 14,
  "shippedToday": 20,
  "_links": {
    "self": { "href": "/orders" },
    "next": { "href": "/orders?page=2" },
    "find": { "href": "/orders{?id}", "templated": true }
  },
  "_embedded": {
    "orders": [
      {
        "_links": {
          "self": { "href": "/orders/123" },
          "basket": { "href": "/baskets/98712" },
          "customer": { "href": "/customers/7809" }
        },
        "total": 30.00,
        "currency": "USD",
        "status": "shipped",
      },
      {
        "_links": {
          "self": { "href": "/orders/124" },
          "basket": { "href": "/baskets/97213" },
          "customer": { "href": "/customers/12369" }
        },
        "total": 20.00,
        "currency": "USD",
        "status": "processing"
      }
    ]
  }
}
```

Let's break it down.
First we have the properties of the list itself:

```json
{
  "currentlyProcessing": 14,
  "shippedToday": 20,
```

Nothing special here.
The next part is more interesting:

```json
"_links": {
  "self": { "href": "/orders" },
  "next": { "href": "/orders?page=2" },
  "find": { "href": "/orders{?id}", "templated": true }
},
```

In HAL+JSON, the reserved `_links` property indicates how to get to relations of the resource with hyperlinks.
The keys in this map are the `rel` or relation property of the link.
In this case, we have the `self` relation which is itself,
the `next` relation to get the next page of orders,
and a `find` relation that can be used to find a specific order.

<a name="custom-media-types"></a>
### Custom Media Types

Lorem ipsum.

### MORE...

HAL+JSON & Curies
Custom Media Types & Media Type Registration RFC

Web Linking & Registered Rel vs. Custom Rel
URI Templates

REST API Versioning

## Meta

* [REST APIs must be hypertext-driven (Untangled, musings of Roy T. Fielding)](http://roy.gbiv.com/untangled/2008/rest-apis-must-be-hypertext-driven)
* [REST is over (Literate Programming)](http://blog.steveklabnik.com/posts/2012-02-23-rest-is-over)
* [Nobody Understands REST or HTTP (Literate Programming)](http://blog.steveklabnik.com/posts/2011-07-03-nobody-understands-rest-or-http)
* [Some People Understand REST and HTTP (Literate Programming)](http://blog.steveklabnik.com/posts/2011-08-07-some-people-understand-rest-and-http)
* [What the hell is a Hypermedia API, and why should I care? (2beards)](http://2beards.net/2012/03/what-the-hell-is-a-hypermedia-api-and-why-should-i-care/)
* [Hypermedia APIs - less hype more media, please (Speaker Deck)](https://speakerdeck.com/pengwynn/hypermedia-apis-less-hype-more-media-please)
* [Web API Versioning Smackdown (Mnot's Blog)](http://www.mnot.net/blog/2011/10/25/web_api_versioning_smackdown)
* [Advantages Of (Also) Using HATEOAS in RESTful APIs (InfoQ)](http://www.infoq.com/news/2009/04/hateoas-restful-api-advantages)
* [How to GET a Cup of Coffee (InfoQ)](http://www.infoq.com/articles/webber-rest-workflow)
* [Designing Hypermedia APIs (steveklabnik@github)](http://steveklabnik.github.io/hypermedia-presentation/)
* [Getting hyper about hypermedia APIs (Signal vs. Noise)](http://37signals.com/svn/posts/3373-getting-hyper-about-hypermedia-apis)

### Relevant RFCs

* [RFC 5988: Web Linking](http://tools.ietf.org/html/rfc5988)
* [RFC 6570: URI Template](http://tools.ietf.org/html/rfc6570)
* [RFC 6838: Media Type Specifications and Registration Procedures](http://tools.ietf.org/html/rfc6838)
* [JSON Hypertext Application Language (draft)](http://tools.ietf.org/html/draft-kelly-json-hal-05)

### And last but not least

Dr. Fielding's dissertation which first defined REST:

* [Architectural Styles and the Design of Network-based Software Architectures](http://www.ics.uci.edu/~fielding/pubs/dissertation/top.htm)
