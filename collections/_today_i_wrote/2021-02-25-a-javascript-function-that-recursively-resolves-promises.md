---
layout: post
title: A JavaScript function that recursively resolves promises
date: '2021-02-25 21:34:43 +0100'
comments: true
today:
  type: wrote
categories: programming
tags: async-await
versions:
  javascript: ECMAScript 2020
---

[Async/await][async-await] is awesome because it enables asynchronous,
promise-based behavior to be written in a cleaner, more imperative-looking
style:

```js
async function computeAsyncStuff() {
  const foo = await computeFoo();
  const bar = await computeBar();
  return foo + bar;
}
```

Want to run things in parallel? Piece of cake, with a nice [destructuring
assignment][destructuring-assignment] as a bonus:

```js
async function computeAsyncStuffInParallel() {
  const [ foo, bar ] = await Promise.all([
    computeFoo(),
    computeBar()
  ]);

  return foo + bar;
}
```

But... *oh no*, it doesn't work with objects:

```js
async function computeAsyncObject() {
  const { foo, bar } = await {
    foo: computeFoo(),
    bar: computeBar()
  };

  console.log(foo); // Promise { ... }
  console.log(bar); // Promise { ... }

  return foo + bar; // '[object Promise][object Promise]'
}
```

<!-- more -->

So I wrote a small function to resolve nested structures of plain arrays and
objects:

```js
async function resolve(value) {
  // Await the value in case it's a promise.
  const resolved = await value;

  if (isPlainObject(resolved)) {
    const entries = Object.entries(resolved);
    const resolvedEntries = entries.map(
      // Recursively resolve object values.
      async ([ key, value ]) => [ key, await resolve(value) ]
    );
    return Object.fromEntries(
      await Promise.all(resolvedEntries)
    );
  } else if (Array.isArray(resolved)) {
    // Recursively resolve array values.
    return Promise.all(resolved.map(resolve));
  }

  return resolved;
}

function isPlainObject(value) {
  return typeof value === 'object' &&
    value !== null &&
    value.constructor === Object;
}
```

Now you can do this:

```js
async function computeAsyncObject() {
  const { foo, bar } = await resolve({
    foo: computeFoo(),
    bar: computeBar()
  });

  console.log(foo); // 14
  console.log(bar); // 28

  return foo + bar; // 42
}
```

You can even do this with arbitrarily nested structures as long as they're only
arrays and plain objects:

```js
async function computeAsyncStructure() {
  const { foo, bar: [ baz, qux ] } = await resolve({
    foo: computeFoo(),
    bar: Promise.resolve([
      computeBaz(),
      computeQux()
    ])
  });

  return foo + baz + qux;
}
```

If you like [Lodash][lodash], here's another version taking advantage of its
utility functions:

```js
const {
  isArray,
  isPlainObject,
  zipObject
} = require('lodash');

async function resolve(value) {
  // Await the value in case it's a promise.
  const resolved = await value;

  if (isPlainObject(resolved)) {
    const keys = Object.keys(resolved);
    // Recursively resolve object values.
    const resolvedValues = await Promise.all(
      Object.values(resolved).map(resolve)
    );
    return zipObject(keys, resolvedValues);
  } else if (isArray(resolved)) {
    // Recursively resolve array values.
    return Promise.all(resolved.map(resolve));
  }

  return resolved;
}
```

The world awaits.

[async-await]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function
[destructuring-assignment]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Destructuring_assignment
[lodash]: https://lodash.com
