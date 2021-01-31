---
layout: post
title: Cool functional programming features may be coming to JavaScript
date: '2021-01-25 10:00:00 +0100'
comments: true
today:
  type: learned
categories: programming
tags: tc39 functional
versions:
  javascript: ECMAScript 2020
---

I've been learning functional programming languages lately, so I was happy to
see some of my favorite functional programming features in the [TC39 stage 1
proposals][tc39-proposals-stage-1].

<!-- more -->

## The pipeline operator

I know the pipe operator [from Elixir][elixir-pipe-operator] and [from
Elm][elm-pipe-operator]. The ECMAScript [pipeline operator
proposal][pipeline-operator-proposal] introduces a similar operator `|>` which
allows you to streamline chained function calls in a readable, functional
manner.

Let's assume you have the following functions available:

```js
function doubleSay(str) {
  return str + ", " + str;
}
function capitalize(str) {
  return str[0].toUpperCase() + str.substring(1);
}
function exclaim(str) {
  return str + '!';
}
```

Chaining them is not very readable because the functions do not execute in the
order they appear in the code. Your brain has to get used to reading them from
the inside to the outside of the chain:

```js
// The order of execution is: doubleSay,
// then capitalize, then exclaim.
let result = exclaim(capitalize(doubleSay("hello")));
console.log(result);  //=> "Hello, hello!"
```

With the new pipeline operator, the following execution would be equivalent and
much more intuitive to read and understand:

```js
let result = "hello"
  |> doubleSay
  |> capitalize
  |> exclaim;

console.log(result);  //=> "Hello, hello!"
```

## Pattern matching

I've used pattern matching [in Elixir][elixir-pattern-matching], [in
Elm][elm-pattern-matching] and [in Rust][rust-pattern-matching]. The ECMAScript
[pattern matching proposal][pattern-matching-proposal] would add a similar
expression based on the existing [destructuring
assignment][destructuring-assignment].

It allows compact destructuring of complex data types in a switch-like manner:

```js
const res = await fetch(jsonService);

case (res) {
  when {status: 200, headers: {'Content-Length': s}} ->
    console.log(`size is ${s}`),
  when {status: 404} ->
    console.log('JSON not found'),
  when {status} if (status >= 400) -> {
    throw new RequestError(res)
  },
}
```

## Partial application

I've used partial application [in Elm][elm-partial-application] and with
the Lodash-like [Ramda library for JavaScript][ramda].

Let's say you have a generic addition function like this:

```js
function add(x, y) {
  return x + y;
}
```

You can use existing JavaScript features to create a partially-applied version
of this function. Let's say you often need to increment by 1 and want to derive
this functionality from the existing function. You could use
[`Function.prototype.bind`][bind]:

```js
const incrementByOne = add.bind(null, 1);
incrementByOne(2); // 3
```

Or you could use an [arrow function][arrow-function]:

```js
const incrementByOne = x => add(x, 10);
incrementByOne(3);  // 4
```

The [partial application proposal][partial-application-proposal] introduces a
more compact way of doing this:

```js
const incrementByOne = add(1, ?);
incrementByOne(4); // 5
```

This would interact very nicely with the previous-mentioned pipeline operator
proposal:

```js
let newScore = clamp(0, 100, add(7, player.score));

// This would be an equivalent expression using
// the pipeline operator and partial application:
let newScore = player.score
  |> add(7, ?)
  |> clamp(0, 100, ?);
```

## Do expressions

I've long enjoyed programming in languages where every expression returns a
value. This is generally the case in functional programming languages like
[Elixir][elixir] and [Elm][elm], but also in some other languages like
[Ruby][ruby].

In JavaScript, this is an expression:

```js
1 + 2
```

You can store its result into a variable:

```js
const value = 1 + 2;
console.log(value);  // 3
```

However, the [if statement][if-statement] in JavaScript is not an expression, so
you cannot do this:

```js
const value = if (someCondition) {
  1
} else if (someOtherCondition) {
  2
} else {
  3
}
```

You are forced to do something like this:

```js
let value;
if (someCondition) {
  value = 1;
} else if (someOtherCondition) {
  value = 2;
} else {
  value = 3;
}
```

The [do expressions proposal][do-expressions-proposal] adds a more
expression-oriented of doing this:

```js
const value = do {
  if (someCondition) {
    1
  } else if (someOtherCondition) {
    2
  } else {
    3
  }
};
```

## Meta

> [TC39][tc39] is a group of JavaScript developers, implementers, academics, and
> more, collaborating with the community to maintain and evolve the definition
> of JavaScript.
>
> The [TC39 proposals][tc39-proposals] are the changes proposed to ECMAScript,
> the JavaScript standard. Stage 1 proposals are early in the
> [process][tc39-process] and have not yet been standardized.

[arrow-function]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Arrow_functions
[bind]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_objects/Function/bind
[destructuring-assignment]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Destructuring_assignment
[do-expressions-proposal]: https://github.com/tc39/proposal-do-expressions
[elixir]: https://elixir-lang.org
[elixir-pattern-matching]: https://elixir-lang.org/getting-started/pattern-matching.html
[elixir-pipe-operator]: https://elixir-lang.org/getting-started/enumerables-and-streams.html#the-pipe-operator
[elm]: https://elm-lang.org
[elm-partial-application]: https://guide.elm-lang.org/appendix/function_types.html#partial-application
[elm-pattern-matching]: https://guide.elm-lang.org/types/pattern_matching.html
[elm-pipe-operator]: https://elm-lang.org/docs/syntax#operators
[if-statement]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/if...else
[partial-application-proposal]: https://github.com/tc39/proposal-partial-application
[pattern-matching-proposal]: https://github.com/tc39/proposal-pattern-matching
[pipeline-operator-proposal]: https://github.com/tc39/proposal-pipeline-operator
[ramda]: https://ramdajs.com
[ruby]: https://www.ruby-lang.org
[rust]: https://www.rust-lang.org
[rust-pattern-matching]: https://doc.rust-lang.org/book/ch18-03-pattern-syntax.html
[tc39]: https://tc39.es
[tc39-process]: https://tc39.es/process-document/
[tc39-proposals]: https://github.com/tc39/proposals
[tc39-proposals-stage-1]: https://github.com/tc39/proposals/blob/master/stage-1-proposals.md
