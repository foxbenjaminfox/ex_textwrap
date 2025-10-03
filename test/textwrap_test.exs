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

    test "wrap algorithm" do
      assert Textwrap.wrap("To be, or not to be, that is the question.", width: 10) ==
               ["To be,", "or not to", "be, that", "is the", "question."]

      assert Textwrap.wrap(
               "To be, or not to be, that is the question.",
               width: 10,
               wrap_algorithm: :optimal_fit
             ) == ["To be,", "or not to", "be, that", "is the", "question."]

      assert Textwrap.wrap(
               "To be, or not to be, that is the question.",
               width: 10,
               wrap_algorithm: :first_fit
             ) == ["To be, or", "not to be,", "that is", "the", "question."]
    end

    test "wrap algorithm with custom penalties" do
      assert Textwrap.wrap(
               "To be, or not to be, that is the question.",
               width: 10,
               wrap_algorithm: {:optimal_fit, %{}}
             ) == ["To be,", "or not to", "be, that", "is the", "question."]

      assert Textwrap.wrap(
               "To be, or not to be, that is the question.",
               width: 10,
               wrap_algorithm: {:optimal_fit, %{overflow_penalty: 1}}
             ) == ["To be, or not to be, that is the question."]

      assert Textwrap.wrap(
               "To be, or not to be, that is the question.",
               width: 10,
               wrap_algorithm:
                 {:optimal_fit,
                  %{
                    nline_penalty: 50,
                    overflow_penalty: 50,
                    hyphen_penalty: 5000
                  }}
             ) == ["To be, or", "not to be,", "that is the", "question."]
    end

    test "word_splitter" do
      assert Textwrap.wrap("elephant", width: 6) == ["elepha", "nt"]
      assert Textwrap.wrap("elephant", width: 6, word_splitter: nil) == ["elepha", "nt"]
      assert Textwrap.wrap("elephant", width: 6, word_splitter: false) == ["elepha", "nt"]
      assert Textwrap.wrap("elephant", width: 6, word_splitter: :en_us) == ["ele-", "phant"]

      assert Textwrap.wrap("cooperation", width: 6) == ["cooper", "ation"]
      assert Textwrap.wrap("co-operation", width: 6) == ["co-", "operat", "ion"]

      assert Textwrap.wrap("cooperation", width: 6, word_splitter: nil) == ["cooper", "ation"]

      assert Textwrap.wrap("co-operation", width: 6, word_splitter: nil) == [
               "co-",
               "operat",
               "ion"
             ]

      assert Textwrap.wrap("cooperation", width: 6, word_splitter: false) == ["cooper", "ation"]
      assert Textwrap.wrap("co-operation", width: 6, word_splitter: false) == ["co-ope", "ration"]

      assert Textwrap.wrap("cooperation", width: 6, word_splitter: :en_us) == [
               "coop-",
               "era-",
               "tion"
             ]

      assert Textwrap.wrap("co-operation", width: 6, word_splitter: :en_us) == [
               "co-",
               "opera-",
               "tion"
             ]
    end

    test "splitter" do
      assert Textwrap.wrap("elephant", width: 6) == ["elepha", "nt"]
      assert Textwrap.wrap("elephant", width: 6, splitter: nil) == ["elepha", "nt"]
      assert Textwrap.wrap("elephant", width: 6, splitter: false) == ["elepha", "nt"]
      assert Textwrap.wrap("elephant", width: 6, splitter: :en_us) == ["ele-", "phant"]

      assert Textwrap.wrap("cooperation", width: 6) == ["cooper", "ation"]
      assert Textwrap.wrap("co-operation", width: 6) == ["co-", "operat", "ion"]

      assert Textwrap.wrap("cooperation", width: 6, splitter: nil) == ["cooper", "ation"]
      assert Textwrap.wrap("co-operation", width: 6, splitter: nil) == ["co-", "operat", "ion"]

      assert Textwrap.wrap("cooperation", width: 6, splitter: false) == ["cooper", "ation"]
      assert Textwrap.wrap("co-operation", width: 6, splitter: false) == ["co-ope", "ration"]

      assert Textwrap.wrap("cooperation", width: 6, splitter: :en_us) == ["coop-", "era-", "tion"]

      assert Textwrap.wrap("co-operation", width: 6, splitter: :en_us) == [
               "co-",
               "opera-",
               "tion"
             ]
    end
  end

  describe "Textwrap.fill/2" do
    test "width as an integer" do
      assert Textwrap.fill("hello world", 5) == "hello\nworld"
    end

    test "width in a keyword list" do
      assert Textwrap.fill("hello world", width: 5) == "hello\nworld"
    end

    test "with custom penalties" do
      assert Textwrap.fill(
               "To be, or not to be, that is the question.",
               width: 10,
               wrap_algorithm: {:optimal_fit, %{}}
             ) == "To be,\nor not to\nbe, that\nis the\nquestion."

      assert Textwrap.fill(
               "To be, or not to be, that is the question.",
               width: 10,
               wrap_algorithm: {:optimal_fit, %{overflow_penalty: 1}}
             ) == "To be, or not to be, that is the question."
    end

    test "parity with Textwrap.wrap/2" do
      for width <- [5, 10],
          break_words <- [true, false],
          initial_indent <- ["", ">"],
          subsequent_indent <- ["", ">"],
          splitter <- [nil, false, :en_us],
          wrap_algorithm <- [
            :first_fit,
            :optimal_fit,
            {:optimal_fit, %{nline_penalty: 50, overflow_penalty: 50, hyphen_penalty: 5000}}
          ] do
        opts = [
          width: width,
          break_words: break_words,
          initial_indent: initial_indent,
          subsequent_indent: subsequent_indent,
          splitter: splitter,
          wrap_algorithm: wrap_algorithm
        ]

        text = "elephant-rhinoceros cooperation"
        wrapped = Textwrap.wrap(text, opts)
        filled = Textwrap.fill(text, opts)

        assert filled == Enum.join(wrapped, "\n")
      end
    end
  end
end
