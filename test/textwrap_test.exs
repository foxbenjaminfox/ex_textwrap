defmodule TextwrapTest do
  use ExUnit.Case
  doctest Textwrap

  describe "Textwrap.wrap/2" do
    test "width as an integer" do
      assert Textwrap.wrap("hello world", 5) == ["hello", "world"]
    end

    test "width in a keyword list" do
      assert Textwrap.wrap("hello world", width: 5) == ["hello", "world"]
    end

    test "break_words" do
      assert Textwrap.wrap("foobarbaz", width: 5) == ["fooba", "rbaz"]
      assert Textwrap.wrap("foobarbaz", width: 5, break_words: true) == ["fooba", "rbaz"]
      assert Textwrap.wrap("foobarbaz", width: 5, break_words: false) == ["foobarbaz"]
    end

    test "indents" do
      assert Textwrap.wrap("foo bar baz", width: 4, initial_indent: " ") == [" foo", "bar", "baz"]

      assert Textwrap.wrap("foo bar baz", width: 4, subsequent_indent: " ") == [
               "foo",
               " bar",
               " baz"
             ]

      assert Textwrap.wrap("foo bar baz",
               width: 4,
               initial_indent: ">",
               subsequent_indent: " "
             ) == [">foo", " bar", " baz"]
    end
  end

  describe "Textwrap.fill/2" do
    test "width as an integer" do
      assert Textwrap.fill("hello world", 5) == "hello\nworld"
    end

    test "width in a keyword list" do
      assert Textwrap.fill("hello world", width: 5) == "hello\nworld"
    end
  end
end
