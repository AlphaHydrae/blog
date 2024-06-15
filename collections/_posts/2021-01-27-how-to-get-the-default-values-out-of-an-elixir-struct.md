---
layout: post
title: How to get the default values out of an Elixir struct
date: '2021-01-27 21:31:02 +0100'
comments: true
today:
  type: learned
categories: programming
tags: elixir
versions:
  elixir: 1.11.3
  erlang: 23.2.3
---

Define a struct with some default values:

```elixir
defmodule Person do
  defstruct [:name, age: 18]
end
```

[Structs have a `__struct__/0` function][defstruct/1] that returns the
struct with its defaults values:

```elixir
Person.__struct__()  # %Person{age: 18, name: nil}
```

Since [structs are maps][structs-are-maps], you can extract each default value
with [`Map.get/3`][Map.get/3]:

```elixir
defaults = Person.__struct__()
Map.get(defaults, :age)   # 18
Map.get(defaults, :name)  # nil
```

You can also use the static access operator (see *Map/struct access* in
[*Writing assertive code with Elixir*][map-access]):

```elixir
defaults = Person.__struct__()
defaults.age   # 18
defaults.name  # nil
```

[defstruct/1]: https://hexdocs.pm/elixir/Kernel.html#defstruct/1
[map-access]: https://dashbit.co/blog/writing-assertive-code-with-elixir
[Map.get/3]: https://hexdocs.pm/elixir/Map.html#get/3
[structs-are-maps]: https://elixir-lang.org/getting-started/structs.html#structs-are-bare-maps-underneath
