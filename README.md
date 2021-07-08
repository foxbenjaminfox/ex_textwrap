# Textwrap

<p align="center">
  <a href="https://github.com/foxbenjaminfox/ex_textwrap">
    <img src="https://img.shields.io/circleci/build/github/foxbenjaminfox/ex_textwrap">
  </a>
  <a href="https://hex.pm/packages/textwrap">
    <img src="https://img.shields.io/hexpm/v/textwrap">
  </a>
  <a href="https://hex.pm/packages/textwrap">
    <img src="https://img.shields.io/hexpm/dt/textwrap">
  </a>
  <a href="https://github.com/foxbenjaminfox/ex_textwrap/blob/master/LICENSE">
    <img src="https://img.shields.io/github/license/foxbenjaminfox/ex_textwrap">
  </a>
</p>

Textwrap is a set of NIF bindings to the [`textwrap`](https://github.com/mgeisler/textwrap) Rust crate, for wrapping, indenting, and dedenting text.

## Installation

This package is [available in Hex](https://hex.pm/packages/textwrap), and can be installed
by adding `textwrap` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:textwrap, "~> 0.1.0"}
  ]
end
```

## Getting Started

Use `fill/2` to get a wrapped string, or `wrap/2` to get a list of wrapped lines:

```elixir
iex> Textwrap.fill("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor", 30)
"Lorem ipsum dolor sit amet,\nconsectetur adipisicing elit,\nsed do eiusmod tempor"

iex> Textwrap.wrap("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor", 30)
["Lorem ipsum dolor sit amet,", "consectetur adipisicing elit,", "sed do eiusmod tempor"]
```

The second argument to `fill/2` or `wrap/2` can instead be a keyword list with the desired width as well as [further options](https://hexdocs.pm/textwrap/Textwrap.html#wrap/2):
```elixir
iex> Textwrap.wrap("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor", width: 30, initial_indent: "> ", subsequent_indent: ">> ")
["> Lorem ipsum dolor sit amet,", ">> consectetur adipisicing", ">> elit, sed do eiusmod tempor"]
```

The width can either be a positive integer, or `:termwidth`. In the latter case, the width of the terminal connected to standard output is used, or a fallback width of 80 otherwise.

See the [API docs](https://hexdocs.pm/textwrap) for more details.

## License

`textwrap` is distributed under the Apache License, version 2.0.
