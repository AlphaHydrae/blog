---
layout: post
title: How to test Elm tuples with Expect.all
date: '2021-06-04 13:25:36 +0200'
comments: true
today:
  type: learned
  past: true
categories: programming
tags: elm testing
versions:
  elm: 0.19.1
---

I've been writing [Elm tests](https://github.com/elm-explorations/test), which
are pretty awesome (:blue_heart: the [`Fuzz`
module](https://package.elm-lang.org/packages/elm-explorations/test/latest/Fuzz)
which provides [fuzz tests](https://en.wikipedia.org/wiki/Fuzzing) out of the
box for example).

This article contains:

* An overview of some of the basic functions in the [`elm-exploration/test`
  package](https://github.com/elm-explorations/test), their types and how they
  fit together. Some of Elm's syntax and functional operators are also explained
  along the way.
* An exploration of how the [`Expect.all`
  function](https://package.elm-lang.org/packages/elm-explorations/test/latest/Expect#all)
  can be used to test tuples;
* An example of how to apply this knowledge to test your typical Elm
  application's `update` function.





## A tale of an Elm test

This is what a typical Elm test file looks like:

```elm
module MainTest exposing (suite)

import Expect
import Test exposing (Test, test)


suite : Test
suite =
    test "1 + 1 equals 2" <|
        \_ ->
            (1 + 1)
            |> Expect.equal 2
```

The syntax looks a bit daunting the first time if you're not used to functional
programming, functional operators or Elm's syntax. Let's demistify this example.
Elm is all about type inference, so let's look at the types.

A test file like the one above must export a test suite of type `Test`, that's
what the following code does:

```elm
suite : Test
suite =
  -- ...
```

When we define a value or function in Elm, we can optionally indicate its type
signature before its definition. In this example, `suite : Test` is the type
signature, while `suite =` and what follows is the definition. The type
signature indicates that `suite` is a value of type `Test`.

> This article only shows a suite with one test, but you can of course create a
> suite composed of multiple tests with the [`Test.describe`
> function](https://package.elm-lang.org/packages/elm-explorations/test/latest/Test#describe).

### `Test.test`

Ok, so we need a `Test`. The [`Test.test`
function](https://package.elm-lang.org/packages/elm-explorations/test/latest/Test#test)
creates one. Its type is:

```
test : String -> (() -> Expectation) -> Test
```

Let's try it in English: the `test` function takes two arguments: a `String`,
and a function that returns an
[`Expectation`](https://package.elm-lang.org/packages/elm-explorations/test/latest/Expect#Expectation)
. Then it returns a `Test`.

Making a `String` is easy enough:

```elm
testDescription : String
testDescription =
    "1 + 1 equals 2"
```

But how do we make an `Expectation`?

### `Expect.equal`

You can use the functions from the [`Expect`
module](https://package.elm-lang.org/packages/elm-explorations/test/latest/Expect),
like the [`Expect.equal`
function](https://package.elm-lang.org/packages/elm-explorations/test/latest/Expect#equal)
which has the following type:

```
equal : a -> a -> Expectation
```

Again in English: the `equal` function takes two arguments of the same type, and
returns an `Expectation`. The lowercase `a` indicates that we don't care which
type, as long as it's the same type twice (you could use any lowercase letter or
word in place of `a`).

Since this is the `equal` function, the returned expectation is that these two
values are equal. Actually checking that expectation is the job of the test
framework.

> In other test frameworks, you might be used to calling the two arguments the
> **expected** value (the value you expect to be produced by the code the test
> is executing) and the **actual** value (the value actually produced by the
> executed code).

So here's an `Expectation` we could create:

```elm
expectation : Expectation
expectation =
    Expect.equal 2 (1 + 1)
```

The **expected** value is `2` in this example. That's what we expect our
computation to produce. And the **actual** value is our computation, in this
case `1 + 1`.

You could write it very verbosely like this:

```elm
expected : number
expected =
    2

actual : number
actual =
    1 + 1

expectation: Expectation
expectation =
    Expect.equal expected actual
```

### An anonymous function

But the `Test.test` function requires an argument of type `() -> Expectation`,
not an `Expectation`. What's that you ask? It's a function that takes the [unit
type
`()`](https://sporto.gitbooks.io/elm-tutorial/content/en/01-foundations/07-unit-type.html)
and returns an `Expectation`. Coming from JavaScript, you might say it's an
anonymous function.

Here's how we could write it:

```elm
testFunc : () -> Expectation
testFunc () =
    Expect.equal 2 (1 + 1)
```

Since the unit type always has the same value and we don't care about it, we
can also replace the argument by `_` to indicate that we don't use the value:

```elm
testFunc : () -> Expectation
testFunc _ =
    Expect.equal 2 (1 + 1)
```

We can also directly define it as an [anonymous
function](https://elm-lang.org/docs/syntax#functions):

```elm
testFunc : () -> Expectation
testFunc =
    \_ -> Expect.equal 2 (1 + 1)
```

It doesn't matter which way you write it. The three function definitions above
are equivalent.

### The test

Let's combine everything we've learned so far to create that test. Define the
two arguments, then pass them to the `test` function:

```elm
suite : Test
suite =
    let
        testDescription : String
        testDescription =
            "1 + 1 equals 2"

        testFunc : () -> Expectation
        testFunc =
            \_ -> Expect.equal 2 (1 + 1)
    in
    test testDescription testFunc
```

Ok, that works, but it doesn't look much like the initial example. Let's inline
the description and test function:

```elm
suite : Test
suite =
    test "1 + 1 equals 2" (\_ -> Expect.equal 2 (1 + 1))
```

That's more like it. But it still doesn't match the example, which also used the
esoteric `<|` and `|>` operators.

### The `<|` operator

The [`<|`
operator](https://package.elm-lang.org/packages/elm/core/latest/Basics#(%3C|))
is one of the dreaded **functional operators** (*cue ominous music*). Its type
signature is:

```
(<|) : (a -> b) -> a -> b
```

The first thing we can see is that, like most things in Elm, `<|` is actually a
function. The fact that it is shown within parentheses in its type definition
indicates that it's an [operator](https://elm-lang.org/docs/syntax#operators).

Unlike other functions, an operator can be used with [infix
notation](https://en.wikipedia.org/wiki/Infix_notation) (between its operands).
For example, `(+)` is also an operator:

```elm
three : number
three =
    1 + 2
```

But really, it's just a function and can be used like one:

```elm
three : number
three =
    (+) 1 2
```

Back to the `<|` operator and its type signature:

```
(<|) : (a -> b) -> a -> b
```

It takes two arguments: a function that transforms an `a` into a `b`, an `a`,
and then it returns a `b`. In other words: it takes an `a` to `b`
transformation, and then transforms an `a` into a `b`.

If you're thinking that all it does is apply the provided transformation, you're
correct. Assuming `f` is your transformation function, calling `f <| x` is
equivalent to simply calling `f x`.

Let's see how this can be applied to our test function:

```elm
suite : Test
suite =
    test "1 + 1 equals 2" (\_ -> Expect.equal 2 (1 + 1))
```

Basically, this would be equivalent:

```elm
suite : Test
suite =
    test "1 + 1 equals 2" <| (\_ -> Expect.equal 2 (1 + 1))
```

What use is this? Well, because the `<|` has [low precedence and is
right-associative](https://guide.elm-lang.org/appendix/function_types.html#partial-application),
you don't need the parentheses any more:

```elm
suite : Test
suite =
    test "1 + 1 equals 2" <| \_ -> Expect.equal 2 (1 + 1)
```

Phew... all this to get rid of some parentheses. Let's format that over more
lines for a bit more clarity:

```elm
suite : Test
suite =
    test "1 + 1 equals 2" <|
        \_ -> Expect.equal 2 (1 + 1)
```

Let's go over what's happening in more details type-wise. The type signature of
the `Test.test` function is:

```
test : String -> (() -> Expectation) -> Test
```

Because Elm has [partial
application](https://guide.elm-lang.org/appendix/function_types.html#partial-application),
when we call `test "1 + 1 equals 2"`, we are in fact creating a new function:

```elm
additionTestCreator : (() -> Expectation) -> Test
additionTestCreator =
    test "1 + 1 equals 2
```

We say the `test` function is *partially applied*: you have given it only one of
its two arguments, and you get back a function which awaits the second argument
before producing the result.

You can create a test with this partially-applied test function by simply
providing the remaining argument:

```elm
suite : Test
suite =
    additionTestCreator (\_ -> Expect.equal 2 (1 + 1))
```

> Partial application is actually a mathematical concept called
> [currying](https://en.wikipedia.org/wiki/Currying), which is how it is often
> referred to in other functional programming languages.

Let me remind you of our earlier test function:

```elm
testFunc : () -> Expectation
testFunc =
    \_ -> Expect.equal 2 (1 + 1)
```

And so the pattern emerges:

```elm
-- This is our a -> b transformation:
additionTestCreator : (() -> Expected) -> Test
additionTestCreator =
    test "1 + 1 equals 2"

-- This is our a:
testFunc : () -> Expected
testFunc =
    \_ -> Expect.equal 2 (1 + 1)

-- Since <| has the following signature:
--   (<|) : (a -> b) -> a -> b
-- We can put the <| operator between additionTestCreator and testFunc to
-- produce a Test:
suite : Test
suite =
    additionTestCreator <| testFunc

-- Or:
suite : Test
suite =
    test "1 + 1 equals 2" <|
        \_ -> Expect.equal 2 (1 + 1)
```

### The `|>` operator

Now for the [`|>`
operator](https://package.elm-lang.org/packages/elm/core/latest/Basics#(|%3E)),
also known as the *pipe* operator. This is a favorite of many functional
programmers. Its type signature is:

```
(|>) : a -> (a -> b) -> b
```

It takes an `a`, a function that transforms `a` to `b`, then returns a `b`.
Similarly to the `<|` operator, it simply applies the provided transformation to
its first argument. `x |> f` is equivalent to `f x`. Although it may look
simple, it can make code much more readable by visually inverting the flow of
data.

The following function takes a list of numbers, turns them into their absolute
value, and returns the highest even number in the list:

```elm
processInput : List Int -> Int
processInput numbers =
    List.maximum (List.filter isEven (List.map abs numbers))
```

You have to read this line from the inside out to understand what it does, which
you may be used to as a programmer, but is not very intuitive. The pipe operator
turns this chain around, making it quite clear what is happening:

```elm
processInput : List Int -> Int
processInput numbers =
    numbers
    |> List.map abs
    |> List.filter isEven
    |> List.maximum
```

We shall use this to change our test's expectation is represented:

```elm
Expect.equal 2 (1 + 1)
```

The pipe operator makes it look like this:

```elm
(1 + 1) |> Expect.equal 2
```

You don't have to write it like this, but what's nice is that it almost reads
like English: "1 + 1 is expected to equal 2". Hence why many Elm programmers
like to use it like this (the documentation of the test package also states it
was designed to be used like this).





## `Expect.all`














However, the question came to mind: how do I make assertions on both elements
of the tuple returned by your typical `update` function?

```elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  -- ...
```

<!-- more -->

It's easy when there is no command:

```elm
test "it works" <|
    \_ ->
        update someMsg someModel
          |> Expect.equal ( expectedModel, Cmd.none )
```

But it's harder when the command isn't `Cmd.none`. There are two problems:

* Elm's
  [`Cmd`](https://package.elm-lang.org/packages/elm/core/latest/Platform.Cmd) is
  an [opaque type](https://dev.to/hecrj/use-opaque-types-in-elm-3oal), meaning
  you cannot see what's inside once it has been created, and you also [cannot
  test for equality, especially when using
  `Cmd.batch`](https://github.com/elm-community/elm-test/issues/220).
* How do you test both elements of the tuple if you don't know exactly what's in
  it, and thus need a more elaborate assertion than `Expect.equal` or
  `Expect.notEqual`?

Regarding the first problem, there are several strategies to make commands more
testable. The following articles and sample application provide various
examples:

* [Testing Cmds in Elm](https://kofi.sexy/blog/testing-cmds-in-elm)
* [Testing Elm
  updates](https://arjanvandergaag.nl/blog/testing-elm-updates.html)
* [The Effect pattern: Transparent updates in
  Elm](http://reasonableapproximation.net/2019/10/20/the-effect-pattern.html)
* [Elm RealWorld example application architected with the Effect
  pattern](https://github.com/dmy/elm-realworld-example-app)

I won't go into details here. I'll settle for testing that the resulting
command is not `Cmd.none`, which can be tested with simple equality.

This article attempts to answer the second question: how do you test both
elements of a tuple separately when you don't know their exact value?

One way is to test them separately. A first test would check the expected model:

```elm
test "the model is correctly updated" <|
    \_ ->
        update someMsg someModel
            |> Tuple.first
            |> Expect.equal (MyMsg value)
```

A second test would check the command:

```elm
test "a command is produced" <|
    \_ ->
        update someMsg someModel
            |> Tuple.second
            |> Expect.notEqual Cmd.none
```

But it's a pain to write two tests for each update call. Another way is to use
[`Expect.all`](https://package.elm-lang.org/packages/elm-explorations/test/latest/Expect#all).
Let's explore the types a little: The signatures of the `Expect.equal/notEqual`
and `Expect.all` functions are:

```
equal : a -> a -> Expectation
notEqual : a -> a -> Expectation
List (subject -> Expectation) -> subject -> Expectation
```

When we call `Expect.equal` with one value, the expected value, we get back
a function typed `a -> Expectation`. That's why we can pipe the actual value
into it for comparison:

```elm
actualValue |> Expect.equal expectedValue
```

As a reminder, the [pipe (`|>`)
operator](https://package.elm-lang.org/packages/elm/core/latest/Basics#(|%3E))
makes `f x` look like `x |> f`, meaning the previous code is the same as:

```elm
Expect.equal expectedValue actualValue
```

You could also rewrite it like this if you wanted to be extra explicit:

```elm
let
    equal : subject -> subject -> Expectation
    equal =
        Expect.equal

    expectSpecificValue : subject -> Expectation
    expectSpecificValue =
        Expect.equal expectedValue

    expectation : Expectation
    expectation =
      expectSpecificValue actualValue
      -- Or: actualValue |> expectSpecificValue
in
expectation
```

So we get `subject -> Expectation` in the intermediate step. That's perfect,
since `Expect.all`'s signature tells us we need a list of that:

```
List (subject -> Expectation) -> subject -> Expectation
```

That means that we could write, for example:

```elm
5 --
|> Expect.all
    [ Expect.greaterThan 1 --
    , Expect.lessThan 10
    ]
```

When you're not used to functional programming operators, your first instinct
may be to use an anonymous function:

```elm
test "the model is correctly updated and a command is produced" <|
    \_ ->
        update msg model
            |> Expect.all
                [ \value -> Expect.equal (MyMsg value) (Tuple.first value)
                , \value -> Expect.notEqual Cmd.none (Tuple.second value)
                ]
```

You could use the [`<|`
operator](https://package.elm-lang.org/packages/elm/core/latest/Basics#(%3C|))
just to get rid of one of the sets of parentheses:

```elm
test "the model is correctly updated and a command is produced" <|
    \_ ->
        update msg model
            |> Expect.all
                [ \value -> Expect.equal (MyMsg value) <| Tuple.first value
                , \value -> Expect.notEqual Cmd.none (Tuple.second value)
                ]
```

Or you could go the other way and use the [pipe (`|>`)
operator](https://package.elm-lang.org/packages/elm/core/latest/Basics#(|%3E)):

```elm
test "the model is correctly updated and a command is produced" <|
    \_ ->
        update msg model
            |> Expect.all
                [ \value -> Tuple.first value |> Expect.equal (MyMsg value)
                , \value -> Expect.notEqual Cmd.none (Tuple.second value)
                ]
```

I ended up using the [function composition (`>>`)
operator](https://package.elm-lang.org/packages/elm/core/latest/Basics#(%3E%3E)):

```elm
test "the model is correctly updated and a command is produced" <|
    \_ ->
        update msg model
            |> Expect.all
                [ Tuple.first >> Expect.equal (MyMsg value)
                , Tuple.second >> Expect.equal 3
                ]
```
