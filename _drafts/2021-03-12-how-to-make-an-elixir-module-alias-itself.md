---
layout: post
title: How to make an Elixir module alias itself
date: '2021-03-12 20:40:21 +0100'
comments: true
today:
  type: learned
categories: programming
versions:
  elixir: 1.11.3
  erlang: 23.2.7
---

Elixir modules are generally named with a hierarchical structure separated by
dots:

```elixir
defmodule MyProject.Thing do
  # ...
end
```

This is just a convention and provides no special functionality. Like [Erlang
modules][erlang-modules], [Elixir modules][elixir-modules] are just atoms,
prefixed with `"Elixir."`:

```elixir
Atom.to_string(List)  # "Elixir.List"
:"Elixir.List"        # List

Atom.to_string(MyProject.Thing)  # "Elixir.MyProject.Thing"
```

You can reference an Elixir module by its full name but that's rather verbose
and repetitive, especially in its own implementation. Here's an example with an
[Elixir struct][elixir-struct] and a function that manipulate it:

```elixir
defmodule MyProject.Thing do
  defstruct [:name, value: 0]

  def awesome(%MyProject.Thing{name: name} = thing) do
    %MyProject.Thing{thing | name: "Awesome #{name}"}
  end
end
```

<!-- more -->

## Using `__MODULE__`

One way to avoid the repetition of the module name is to use [the `__MODULE__/0`
macro from `Kernel.SpecialForms`][elixir-__MODULE__]. It returns the current
module name as an atom:

```elixir
defmodule MyProject.Thing do
  defstruct [:name, value: 0]

  def awesome(%__MODULE__{name: name} = thing) do
    %__MODULE__{thing | name: "Awesome #{name}"}
  end
end
```

Although the module name is no longer repeated, this may not be the most
readable version.

## Using an alias

Another way to avoid too much repetition is to use [an alias][elixir-alias]:

```elixir
defmodule MyProject.Thing do
  defstruct [:name, value: 0]

  alias MyProject.Thing, as: Thing

  def awesome(%Thing{name: name} = thing) do
    %Thing{thing | name: "Awesome #{name}"}
  end
end
```

This is a bit more readable.

Since aliases are often used as shortcuts for the last part of the module name
like this, it is the default behavior if you don't specify a name:

```elixir
# These two aliases are equivalent:
alias MyProject.Thing
alias MyProject.Thing, as: Thing
```

You can also alias an Elixir module to whatever name you want if you prefer:

```elixir
alias MyProject.Thing, as: Foo
```

## Making a module alias itself

Ok, so an alias is good, but the solution above still makes you repeat the full
module name twice. However, you can combine it with `__MODULE__` and get the
best of both worlds:

```elixir
defmodule MyProject.Thing do
  defstruct [:name, value: 0]

  alias __MODULE__

  def awesome(%Thing{name: name} = thing) do
    %Thing{thing | name: "Awesome #{name}"}
  end
end
```

This way you both avoid the repetition of the full name *and* can use the more
readable `Thing` instead of `__MODULE__` in the rest of the code.

## Credits

[{% img float-right w-full ml-3 mb-3 sm:w-1/2 sm:-mt-12 {{ site.baseurl }}/assets/books/functional-web-development-with-elixir-otp-and-phoenix.jpg %}][book]

I learned this while reading chapter 2 of [*Functional Web Development with
Elixir, OTP, and Phoenix, Rethink the Modern Web App* by Lance Halvorsen][book].

[book]: https://pragprog.com/titles/lhelph/functional-web-development-with-elixir-otp-and-phoenix/
[elixir-__MODULE__]: https://hexdocs.pm/elixir/Kernel.SpecialForms.html#__MODULE__/0
[elixir-alias]: https://elixir-lang.org/getting-started/alias-require-and-import.html#alias
[elixir-modules]: https://elixir-lang.org/getting-started/modules-and-functions.html
[elixir-struct]: https://elixir-lang.org/getting-started/structs.html
[erlang-modules]: http://erlang.org/doc/reference_manual/modules.html
