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
is more generic, scalable and extensible than SOAP and RPC. Or do they?

Like many I started writing REST APIs [the Rails way](http://guides.rubyonrails.org/routing.html#resource-routing-the-rails-default)
because Rails provides everything you need to quickly write a beautiful REST API out of the box.
Or so I thought.

After reading many articles and many more comments,
I now understand that most so-called REST APIs today are not actually RESTful according to how it was originally defined.
Many proponents of "true REST APIs" now seem to prefer talking about **Hypermedia APIs** which is a more practical description of what they are.
You'll also hear about the [**HATEOAS**](http://en.wikipedia.org/wiki/HATEOAS) principle, meaning **Hypermedia As The Engine Of Application State**, one of the constraints of the REST architecture.

Now I don't have a doctorate in computer science;
I'm just a lowly software engineer trying to code some APIs.
A big part of software engineering is making trade-offs.
But you have to understand what you're trading off.

For the rest of this post, I'm going to put on my "True Hypermedia API" zealot hat.
Aside from point 1, this post reflects my (condensed) understanding of what REST/Hypermedia APIs principles are, and how they can be put into practice.

Note that many people disagree that this is how it should be done.
If you're interested in knowing more, I've listed the articles I found most useful to understand the subject at the bottom of this post.
The comments sections of these articles are particularly interesting as they contain descriptions of actual problems, possible solutions, and mostly thoughtful criticism.

A fair warning to those who may read on: this is a [tl;dr]({{ root_url }}/images/contents/general/tldr-cat.jpg) kind of post.

<!-- more -->

1. [REST: The Rails Way](#rest-rails)
1. [Hypermedia APIs](#hypermedia-apis)
1. [Media Types](#media-types)
    * [Hypertext Application Language (HAL)](#hal)
    * [Custom Media Types](#custom-media-types)
1. [The Link Header](#link-header)
1. [URI Templates](#uri-templates)
1. [API Workflow &amp; Caching](#caching)
1. [API Versioning](#api-versioning)
1. [Final Comments](#final-comments)

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

["REST APIs must be hypertext-driven"](http://roy.gbiv.com/untangled/2008/rest-apis-must-be-hypertext-driven) wrote Dr. Fielding in a rant against RPC blasphemers.
What does he mean by that?
And what's up with this hyper stuff about hyperlinks and hypermedia?
Why should I go through all this trouble anyway?

One word: the **Web.**

When you want to browse a website, there are basically two things you need to know about: the root URL, and that you can follow links to new information.
This is the simple but powerful concept of hyperlinks that has made the web so successful.

From a technical point of view, the client is getting a representation of a resource
in the `text/html` [Internet Media Type](https://en.wikipedia.org/wiki/Internet_media_type)
(formerly known as MIME Type); this media type defines the behavior of links.
The knowledge of the root URL and of the media type is sufficient to drive the interaction.
Even if the other URLs of the website change, they can be reached again from the root URL through links.

Hypermedia APIs are based on the same principle.

{% blockquote Roy T. Fielding http://roy.gbiv.com/untangled/2008/rest-apis-must-be-hypertext-driven REST APIs must be hypertext-driven %}
A REST API should be entered with no prior knowledge beyond the initial URI (bookmark) and set of standardized media types that are appropriate for the intended audience (i.e., expected to be understood by any client that might use the API).
{% endblockquote %}

Contrary to the previous notion of REST, there should be:

* No fixed URLs.
* No fixed resource names or hierarchies.

When designing an API, what you should spend time defining are the **media types** used for representing resources.
These media types define relations to other resources through **hyperlinks**;
they drive the application state, hence *Hypermedia As The Engine Of Application State.*

<a name="media-types"></a>
## Media Types

*So what is this *media type* of which you speak?*

Surely we're going to use JSON for our API... right?
Almost. The problem is that `application/json` is not a hypermedia because it's not aware of links.
There's nothing in the JSON specification that tells a client that this `person_url` property you're using is actually a link.
It's not impossible to just use `application/json`, but there are benefits to using hyperlink-aware media types.

I'm not an expert (yet), but I'll outline the two solutions I've most read about: Hypertext Application Language and custom media types.

{% img right /images/contents/hypermedia/hal+json.png 400 %}

<a name="hal"></a>
### Hypertext Application Language (HAL)

[HAL](http://stateless.co/hal_specification.html) is a generic JSON/XML media type for representing resources and their relations with hyperlinks.

Let's jump right into it. The following example document represents a list of orders:

<br style="clear:both" />

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

In the JSON version of HAL, the reserved `_links` property indicates how to get to related resources with hyperlinks.
The keys in this map represent the **rel** or **relation** property of the link (the same you would find in an HTML link: `<link rel="stylesheet" ...>`).
In this case, we have the `self` relation which is itself,
the `next` relation which indicates where to get the next page of orders,
and a `find` relation that can be used to find a specific order.

And as you can see, the last part of the document under the reserved `_embedded` property contains embedded objects, which are also resources with links.
You can have multiple lists of embedded objects; here there is just one under `orders`:

```json
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
```

The goal of HAL is to provide a standardized media type that describes hyperlinks and embedded resources.
That way you don't have to use linkless JSON/XML or develop your own media type (we'll talk about that one later).
If you use HAL, you can focus on describing the link relations that drive your application.

Since HAL is a standard, there are libraries that can help parse and generate it (you'll find a list on the [specification page](http://stateless.co/hal_specification.html)).
There are even [HAL browsers](https://github.com/mikekelly/hal-browser) that can automatically discover HAL APIs.
You can easily find live examples with Google.

<a name="link-relation-types"></a>
#### Link Relation Types

The relation property of a link in HAL (`self`, `next`, etc) is defined in [Web Linking (RFC 5988)](http://tools.ietf.org/html/rfc5988).
In a nutshell, there are two kinds of relations: **Registered Relation Types** and **Extension Relation Types**.

Registered relation types such as *self*, *next*, *previous*, *related* are officially listed by the RFC and have a specific meaning.
You can use them as long as you respect their semantics.

```json
"_links": {
  "self": { "href": "/orders" },
  "next": { "href": "/orders?page=2" }
}
```

You will of course need other relation types that are specific to your domain model, such as a `customer` link in the full document example you saw earlier.
This is what extension relation types are for.
According to the RFC, extension types should be URIs that uniquely identify the relation type.
For example:


```json
"_links": {
  "http://my-api.com/media/orders": { "href": "/orders" },
  "http://my-api.com/media/orders/next": { "href": "/orders?page=2" }
}
```

These URIs may point to a resource that describes the semantics of the relation type, such as a documentation page or a PDF on your website.
If you don't want to use full URIs as relation keys, you have to make sure that they can be expanded to URIs, by using for example the [CURIE Syntax](http://www.w3.org/TR/curie/):

```json
"_links": {
  "curies": [
    {
      "name": "ex",
      "href": "http://my-api.com/media/"
    }
  ],
  "ex:orders": { "href": "/orders" },
  "ex:orders/next": { "href": "/orders?page=2" }
}
```

That's it for HAL.

{% img right /images/contents/hypermedia/at.png 200 %}

<a name="custom-media-types"></a>
### Custom Media Types

Now let's talk about custom media types.
Many Hypermedia folks seem to advocate this solution.

The idea is to define your own media types which describe the representations of your resources as well as the links between them.
What a media type should be, how it should be named and how it should be registered is defined in
[Media Type Specifications and Registration Procedures (RFC 6838)](http://tools.ietf.org/html/rfc6838).
Official registration may not be necessary depending on who is going to use your API, but it's useful if you're hoping to create a shared standard.

I won't go too much into details about this RFC but I'll give you a real-world example:
[GitHub uses media types for its API](http://developer.github.com/v3/media/).
For example, you can use the `application/vnd.github.beta.text+json` media type to retrieve a comment's body.
Let's break that down:

* `application` is for data that does not fit under other top-level media types such as text or audio.
* `vnd` is the prefix for the vendor tree, reserved for media types of publicly available products.
* `github` is the name of the media type.
* `beta` is a parameter that GitHub uses to indicate the version of the API (soon to be `v3`).
* `text` is another parameter to indicate the desired representation, in this case plain text.
* `+json` at the end indicates the underlying structure of the media type (the responses of their API are always in JSON).

Check out the RFC if you want to know how to build your media type.
In this case, the the response might look something like this (partial headers):

```json
HTTP/1.1 200 OK
Server: nginx
Date: Fri, 12 Oct 2012 23:33:14 GMT
Content-Type: application/vnd.github.beta.text+json; charset=utf-8

{
  "body_text": "This commit is awesome."
}
```

This has no links though.
Imagine a media type `vnd.myapi.orders+json` representing a list of orders like the HAL example.
The response might look like this:

```json
HTTP/1.1 200 OK
Server: nginx
Date: Fri, 12 Oct 2012 23:33:14 GMT
Content-Type: application/vnd.myapi.orders+json; charset=utf-8

{
  "url": "/orders",
  "next_url": "/orders?page=2",
  "find_url": "/orders{?id}",
  "currentlyProcessing": 14,
  "shippedToday": 20,
  "orders": [
    {
      "url": "/orders/123",
      "basket_url": "/baskets/98712",
      "customer_url": "/customers/7809",
      "total": 30.00,
      "currency": "USD",
      "status": "shipped"
    }
  ]
}
```

Instead of having a standard syntax for hyperlinks like HAL, the custom media type must define the relations.
The documentation page for this media type might for example indicate that the `url` property is a hyperlink to the resource itself,
whereas `basket_url` is a hyperlink to a resource which can be represented with another media type such as `vnd.myapi.basket+json`.
For HTTP APIs, the media type may also describes what HTTP verbs are applicable and the associated behavior.

All the media types used by your API must be part of the contract with the API clients, but the URL structure is allowed to change independently.

<a name="link-header"></a>
## The Link Header

Whether you choose HAL or custom media types, the [HTTP Link Header](http://www.w3.org/Protocols/9707-link-header.html) can also be used to provide hyperlinks.
A link header looks like this:

```
Link: </orders?page=2>; rel="next"; title="Next page of orders"
```

You can provide multiple link headers, or multiple links in one header:

```
Link: </orders?page=1>; rel="prev", </orders?page=2>; rel="next"
```

This can be a quick way to add true hyperlinks to your API without immediately changing the response format or defining a custom media type.

Note that [Web Linking (RFC 5988)](http://tools.ietf.org/html/rfc5988) defines that extension relation types
(your custom business types) in link headers are *required* to be absolute URIs, for example:

```
Link: </baskets/98712>; rel="http://my-api.com/media/basket";
 title="The basket containing the ordered items"
```

<a name="uri-templates"></a>
## URI Templates

[URI Template (RFC 6570)](http://tools.ietf.org/html/rfc6570) defines a useful format to describe a range of URIs through variable expansion.
You can use it to provide more information about URI parameters in your API.

As a quick example taken from the RFC, imagine that you have these parameterized URLs:

```
http://example.com/~fred/
http://example.com/~mark/

http://example.com/dictionary/c/cat
http://example.com/dictionary/d/dog

http://example.com/search?q=cat&lang=en
http://example.com/search?q=chien&lang=fr
```

You can express them as URI templates:

```
http://example.com/~{username}/
http://example.com/dictionary/{term:1}/{term}
http://example.com/search{?q,lang}
```

The RFC describes the support expression expansions.
I encourage you to read and use it.

<a name="caching"></a>
## API Workflow &amp; Caching

Now you will surely ask, as many have before you:

{% blockquote Angry Developer, Somewhere on the internet %}
Do you really expect me to go through all those link relations to get at my resource? Can't I just go to the URL directly?
{% endblockquote %}

No, you can't.
Not if you want to follow the principles of REST and Hypermedia APIs.
You're *supposed* to follow these relations in order to reduce the client/server coupling and allow the URL structure to evolve independently.
The URLs should not even be in your documentation (aside from the root).

Let's take the previous example of the list of orders.
Assume you have an order ID and want to get a JSON representation of that order.
Also assume that the only knowledge you have is the root of the API and the custom media types it uses.

You must first find the orders resource from the root:

```json
$> curl -H 'Accept: application/vnd.myapi+json' /
HTTP/1.1 200 OK
Content-Type: application/vnd.myapi+json; charset=utf-8

{
  "url": "/",
  "docs_url": "/docs",
  "orders_url": "/orders"
}
```

You would know from the documentation of the `application/vnd.myapi+json` media type
that the `orders_url` property is a hyperlink to the resource you're looking for, and that this resource has
a representation in some media type like `application/vnd.myapi.orders+json`.
Let's GET that:

```json
$> curl -H 'Accept: application/vnd.myapi.orders+json' /orders
HTTP/1.1 200 OK
Content-Type: application/vnd.myapi.orders+json; charset=utf-8

{
  "url": "/orders",
  "next_url": "/orders?page=2",
  "find_url": "/orders{?id}",
  "currentlyProcessing": 14,
  "shippedToday": 20,
  "orders": [
    ...
  ]
}
```

Again, from the media type you would know that you can find the resource you need through the templated `find_url` hyperlink:

```json
$> curl -H 'Accept: application/vnd.myapi.order+json' /orders?id=425
HTTP/1.1 200 OK
Content-Type: application/vnd.myapi.order+json; charset=utf-8

{
  "url": "/orders/123",
  "basket_url": "/baskets/98712",
  "customer_url": "/customers/7809",
  "total": 30.00,
  "currency": "USD",
  "status": "shipped"
}
```

Or you could imagine getting an HTTP 302 redirect to that resource.
That's three calls to get to the order resource you were looking for.

**_Unacceptable!_** you say?
Well that's how Hypermedia APIs work, one of the goals being not to have URLs that cannot change.

However, you can build on top of standard HTTP caching mechanisms to mitigate those issues.
All responses may contain `Cache-Control`, `Expires`, `Last-Modified-Since`, `ETag` and other cache control headers.
Clients may then send headers like `If-Modified-Since` and `If-None-Match` and get back an
*HTTP 304 Not Modified* response if the resources (and their URLs) have not changed.

In most cases the first two calls will be much faster with little data traveling over the wire.
You don't necessarily have to do it yourself; some well-behaved HTTP libraries can handle it for you.

This is all described in [Hypertext Transfer Protocol -- HTTP/1.1 (RFC 2616)](http://tools.ietf.org/html/rfc2616),
notably [Section 13 - Caching in HTTP](http://www.w3.org/Protocols/rfc2616/rfc2616-sec13.html).
I strongly suggest you read up on this if you haven't already.

<a name="api-versioning"></a>
## API Versioning

Over time your API will inevitably change:
new features will be added;
existing features will be changed;
old features will be removed.
How can backward- and forward-compatibility with API clients be maintained?

There is heated debate over how to handle this issue in REST APIs.
I've mostly seen four options that I'll describe here.

### URI Versioning

Theoretically this is not RESTful.
Even if the resource changes in backward-incompatible ways,
as long as it's still basically the same resource there's no reason its URI (resource identifier) should change.

However, it is a simple solution to support multiple versions of an API at the same time.
As long as your backend can handle it, releasing a version 2 under a different URI ensures that version 1 clients will continue to function.
Be aware though that your clients will be strongly coupled with one version, and that it might be difficult to upgrade them.

```
http://my-api.com/v1/orders
http://my-api.com/v2/orders
```

In most cases, it is recommended that you only use a major version number.
A scheme like [semantic versioning](http://semver.org) would be overkill for an API.
Additions and backward-compatible changes should not increase the version number.

Most API developers have chosen the URI versioning solution because it is practical,
but most Hypermedia advocates I've read consider it unRESTful.

### No Versioning

I've seen people writing that you should not version an API because it hinders its evolution.
If you have changes so big that they're completely backward-incompatible, they should be represented as new resources or new links within a resource.
I haven't seen any example of this but I wonder if that might not lead resources to become a messy pile of too many links.

### Link Versioning

A solution similar to new links is to version links within a resource.

```json
{
  "v1_basket_url": "http://my-api.com/baskets/123",
  "v2_basket_url": "http://my-api.com/orders/234/basket"
}
```

That way it's still possible to have multiple behaviors of the same resources in parallel without changing the original URIs.
You just have to update the definition of the media types to describe those new links.

### Media Type Versioning

If a resource has backward-incompatible changes that do fit within its media type definition any more, then a new media type can be defined.
For example, you might go from `application/vnd.myapi.v1+json` to `application/vnd.myapi.v2+json`.
The URI has not changed; the new version is essentially just another representation of the same resource, documented separately.
Different representations can be used by different clients.

On the whole, most Hypermedia API articles I've read that are not about HAL prefer this solution.
It seems to best fit REST and Hypermedia principles.

<a name="final-comments"></a>
## Final Comments

{% img right /images/contents/hypermedia/zealot.png 300 %}

Let me take the zealot hat off.

I don't think that Hypermedia APIs are harder to implement than so-called false REST APIs.
You just have to focus on media types and to make sure that the documentation reflects the hypertext-driven nature of the API, not the URL structure.
Like all APIs, it helps if you design your resources carefully to avoid as many changes as possible in the future.

Hypermedia APIs are not a silver bullet.
Clients still must know your media types and/or relation types.
No automated client will be able to automatically discover an API specific to your application or business.

Hypermedia APIs also place a greater burden on their clients:
they must use the API through link relations instead of hard-coded URLs, and should make use of caching for maximum efficiency.
However, if correctly implemented it does reduce the coupling between server and client.

{% blockquote Roy T. Fielding http://roy.gbiv.com/untangled/2008/rest-apis-must-be-hypertext-driven REST APIs must be hypertext-driven %}
REST is software design on the scale of decades: every detail is intended to promote software longevity and independent evolution.
{% endblockquote %}

I can't say that I understand all those details yet.
I can say that REST and Hypermedia principles have been carefully designed to solve these problems,
and that there's a myriad of RFCs and other specifications to standardize how to deal with them.

If you don't understand Hypermedia APIs yet, it's definitely worth looking into before dismissing them as impractical.
There are pros and cons to both solutions.
Once you understand these, choose what is most appropriate for your needs.

As for me, I will develop my next APIs as Hypermedia APIs to see if I can benefit from those principles in practice.

May your API clients never break.

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
* [HAL+JSON Specification](http://stateless.co/hal_specification.html)
* [Getting hyper about hypermedia APIs (Signal vs. Noise)](http://37signals.com/svn/posts/3373-getting-hyper-about-hypermedia-apis)
* [Cool URIs don't change (W3C)](http://www.w3.org/Provider/Style/URI.html)

### Relevant RFCs

* [RFC 2616: Hypertext Transfer Protocol -- HTTP/1.1](http://tools.ietf.org/html/rfc2616)
* [RFC 5988: Web Linking](http://tools.ietf.org/html/rfc5988)
* [RFC 6570: URI Template](http://tools.ietf.org/html/rfc6570)
* [RFC 6838: Media Type Specifications and Registration Procedures](http://tools.ietf.org/html/rfc6838)
* [JSON Hypertext Application Language (draft)](http://tools.ietf.org/html/draft-kelly-json-hal-05)

### Architectural Styles and the Design of Network-based Software Architectures

Roy T. Fielding's doctoral dissertation which first defined REST.

* [HTML Version](http://www.ics.uci.edu/~fielding/pubs/dissertation/top.htm)
* [PDF Version](http://www.ics.uci.edu/~fielding/pubs/dissertation/fielding_dissertation.pdf)
