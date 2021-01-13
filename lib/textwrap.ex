defmodule Textwrap do
  use Rustler, otp_app: :textwrap, crate: "textwrap_nif"

  @type wrap_opts() :: pos_integer() | :termwidth | [wrap_opt()]
  @type wrap_opt() ::
          {:width, pos_integer() | :termwidth}
          | {:break_words, bool()}
          | {:initial_indent, String.t()}
          | {:splitter, nil | :en_us | false}
          | {:subsequent_indent, String.t()}
          | {:wrap_algorithm, wrap_algorithm()}
  @type wrap_algorithm() :: :first_fit | :optimal_fit

  @spec wrap(text :: String.t(), opts :: wrap_opts()) :: [String.t()]

  @doc """
  Wraps text to the given width.

  `wrap/2` returns a list of `Strings`, each of no more than `width` charecters.

  Options can be either passed as a keyword list (which must include the key `:width`),
  or, if using no options other than `:width`, the width can be passed on its own as
  the second argument.

  `width` can either by a positive integer or the atom `:termwidth`. See the
  [module docs](#module-terminal-width) on `:termwidth` for more details.

  ## Options
     - `:width` — the width to wrap at, a positive integer.
     - `:break_words` — allow long words to be broken, if they won't fit on a single line. Setting this to false may cause some lines to be longer than `:width`.
     - `:inital_indent` — will be added as a prefix to the first line of the result.
     - `:subsequent_indent` — will be added as a prefix to each line other than the first line of the result.
     - `:splitter` — when set to `false`, hyphens within words won't be treated specially as a place to split words. When set to `:en_us`, a language-aware hyphenation system will be used to try to break words in appropriate places.
     - `:wrap_algorithm` — by default, or when set to `:optimal_fit`, `wrap/2` will do its best to
        balance the gaps left at the ends of lines. When set to `:first_fit`, a simpler greedy algorithm
        is used instead. See the docs in the [`textwrap` crate](https://docs.rs/textwrap/0.13.2/textwrap/core/enum.WrapAlgorithm.html) for more details.

  ## Examples
      iex> Textwrap.wrap("hello world", 5)
      ["hello", "world"]

      iex> Textwrap.wrap("hello world", width: 5)
      ["hello", "world"]

      iex> Textwrap.wrap("Antidisestablishmentarianism", width: 10)
      ["Antidisest", "ablishment", "arianism"]

      iex> Textwrap.wrap("Antidisestablishmentarianism", width: 10, break_words: false)
      ["Antidisestablishmentarianism"]

      iex> Textwrap.wrap("Antidisestablishmentarianism", width: 10, splitter: :en_us)
      ["Antidis-", "establish-", "mentarian-", "ism"]

      iex> Textwrap.wrap("foo bar baz",
      ...>      width: 5,
      ...>      initial_indent: "> ",
      ...>      subsequent_indent: "  ")
      ["> foo", "  bar", "  baz"]

      iex> Textwrap.wrap("Lorem ipsum dolor sit amet, consectetur adipisicing elit",
      ...>      width: 25,
      ...>      wrap_algorithm: :optimal_fit)
      ["Lorem ipsum dolor", "sit amet, consectetur", "adipisicing elit"]

      iex> Textwrap.wrap("Lorem ipsum dolor sit amet, consectetur adipisicing elit",
      ...>      width: 25,
      ...>      wrap_algorithm: :first_fit)
      ["Lorem ipsum dolor sit", "amet, consectetur", "adipisicing elit"]
  """

  def wrap(text, width_or_opts)

  def wrap(text, width) when is_integer(width) or width == :termwidth do
    wrap(text, width: width)
  end

  def wrap(text, opts) do
    width = fetch_width!(opts)
    wrap_nif(text, width, opts)
  end

  @spec fill(text :: String.t(), opts :: wrap_opts()) :: String.t()

  @doc """
  Fills text to the given width.

  The result is a `String`, with lines seperated by newline.
  The `wrap/2` function does the same thing, except that it returns a list of `Strings`,
  one for each line.

  See the docs for `wrap/2` for details about the options it takes.

  ## Examples
      iex> Textwrap.fill("hello world", 5)
      "hello\\nworld"

      iex> Textwrap.fill("hello world", width: 5)
      "hello\\nworld"

      iex> Textwrap.fill("Antidisestablishmentarianism", width: 10)
      "Antidisest\\nablishment\\narianism"

      iex> Textwrap.fill("Antidisestablishmentarianism", width: 10, break_words: false)
      "Antidisestablishmentarianism"

      iex> Textwrap.fill("Antidisestablishmentarianism", width: 10, splitter: :en_us)
      "Antidis-\\nestablish-\\nmentarian-\\nism"

      iex> Textwrap.fill("foo bar baz",
      ...>      width: 5,
      ...>      initial_indent: "> ",
      ...>      subsequent_indent: "  ")
      "> foo\\n  bar\\n  baz"

      iex> Textwrap.fill("Lorem ipsum dolor sit amet, consectetur adipisicing elit",
      ...>      width: 25,
      ...>      wrap_algorithm: :optimal_fit)
      "Lorem ipsum dolor\\nsit amet, consectetur\\nadipisicing elit"

      iex> Textwrap.fill("Lorem ipsum dolor sit amet, consectetur adipisicing elit",
      ...>      width: 25,
      ...>      wrap_algorithm: :first_fit)
      "Lorem ipsum dolor sit\\namet, consectetur\\nadipisicing elit"
  """

  def fill(text, width_or_opts)

  def fill(text, width) when is_integer(width) or width == :termwidth do
    fill(text, width: width)
  end

  def fill(text, opts) do
    width = fetch_width!(opts)
    fill_nif(text, width, opts)
  end

  @spec dedent(text :: String.t()) :: String.t()

  @doc """
  Removes as much common leading whitespace as possible from each line.

  Each non-empty line has an equal amount of whitespace removed from its start.

  Empty lines (containing only whitespace) are normalized to a single `\\n`, with no other whitespace on the line.

  ## Examples:

      iex> Textwrap.dedent("    hello world")
      "hello world"

      iex> Textwrap.dedent("
      ...>  foo
      ...>    bar
      ...>  baz
      ...>      ")
      "\\nfoo\\n  bar\\nbaz\\n"

  """
  def dedent(_text), do: :erlang.nif_error(:nif_not_loaded)

  @spec indent(text :: String.t(), prefix :: String.t()) :: String.t()

  @doc """
  Adds a given prefix to each non-empty line.

  Empty lines (containing only whitespace) are normalized to a single `\\n`, and not indented.

  Any leading and trailing whitespace on non-empty lines is left unchanged.

  The returned string will always end with a newline.

  Examples:
      iex> Textwrap.indent("hello world", ">")
      ">hello world\\n"

      iex> Textwrap.indent("foo\\nbar\\nbaz\\n", "  ")
      "  foo\\n  bar\\n  baz\\n"
  """
  def indent(_text, _prefix), do: :erlang.nif_error(:nif_not_loaded)

  defp fill_nif(_text, _width, _opts), do: :erlang.nif_error(:nif_not_loaded)
  defp wrap_nif(_text, _width, _opts), do: :erlang.nif_error(:nif_not_loaded)

  defp fetch_width!(opts) do
    case Keyword.fetch!(opts, :width) do
      :termwidth -> termwidth()
      width -> width
    end
  end

  defp termwidth, do: :erlang.nif_error(:nif_not_loaded)
end
