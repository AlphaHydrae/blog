---
layout: post
title: eslint-plugin-functional, an ESLint plugin to promote functional programming
date: '2021-01-02 19:00:00 +0100'
comments: true
today:
  type: found
categories: programming
tags: eslint javascript typescript functional
versions:
  javascript: ECMAScript 2020
  typescript: 4.x
  eslint: 7.x
  eslint-plugin-functional: 3.x
---

[eslint-plugin-functional] is an [ESLint][eslint] plugin to disable mutation and
promote functional programming in JavaScript.

This can be very useful in projects using [React][react], [Redux][redux] or
similar libraries, which [require or at least recommend using immutable
data][immutability].

<!-- more -->

## Enforcing immutability

For example, the [`immutable-data` rule][immutable-data-rule] forbids you to
mutate objects and arrays:

```js
const obj = { foo: 'bar' };
// Modifying an existing object/array is not allowed!
obj.bar = 'baz';
```

Forcing you to create a new derived object:

```js
const obj = { foo: 'bar' };
const obj2 = { ...obj, bar: 'baz' };
```

## Preferring read-only types

If you're using [TypeScript][typescript], you can use the
[`prefer-readonly-type` rule][prefer-readonly-type-rule] to enforce declaring
interface/type properties as read-only. The following would be invalid with this
rule:

```ts
interface Point {
  x: number;
  y: number;
}
```

While this would be valid:

```ts
interface Point {
  readonly x: number;
  readonly y: number;
}
```

[eslint]: https://eslint.org
[eslint-plugin-functional]: https://www.npmjs.com/package/eslint-plugin-functional
[immutable-data-rule]: https://github.com/jonaskello/eslint-plugin-functional/blob/HEAD/docs/rules/immutable-data.md
[immutability]: https://redux.js.org/faq/immutable-data
[prefer-readonly-type-rule]: https://github.com/jonaskello/eslint-plugin-functional/blob/HEAD/docs/rules/prefer-readonly-type.md
[react]: https://reactjs.org
[redux]: https://redux.js.org
[typescript]: https://www.typescriptlang.org
