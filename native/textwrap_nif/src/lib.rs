use hyphenation::{Language, Load, Standard};
use rustler::types::{atom::false_, atom::nil, Atom};
use rustler::{Error, ListIterator, NifResult, Term};
use std::borrow::Cow;
use textwrap::WordSplitter;

mod wrap_algorithm;
mod atom {
    rustler::atoms! {
        break_words,
        initial_indent,
        splitter,
        word_splitter,
        subsequent_indent,
        wrap_algorithm,

        first_fit,
        optimal_fit,

        en_us,

        nline_penalty,
        overflow_penalty,
        short_last_line_fraction,
        short_last_line_penalty,
        hyphen_penalty,
    }
}

#[rustler::nif]
pub fn fill_nif(text: &str, width: usize, opts: ListIterator<'_>) -> NifResult<String> {
    let options = wrap_options(width, opts)?;
    Ok(textwrap::fill(text, options))
}

#[rustler::nif]
pub fn wrap_nif(text: &str, width: usize, opts: ListIterator<'_>) -> NifResult<Vec<String>> {
    let options = wrap_options(width, opts)?;
    Ok(textwrap::wrap(text, options)
        .into_iter()
        .map(Cow::into_owned)
        .collect())
}

#[rustler::nif]
pub fn dedent(text: &str) -> String {
    textwrap::dedent(text)
}

#[rustler::nif]
pub fn indent(text: &str, prefix: &str) -> String {
    textwrap::indent(text, prefix)
}

#[rustler::nif]
pub fn termwidth() -> usize {
    textwrap::termwidth()
}

fn wrap_options<'a>(width: usize, opts: ListIterator<'a>) -> NifResult<textwrap::Options<'a>> {
    let mut options = textwrap::Options::new(width);

    for opt in opts {
        match opt.decode::<(Atom, Term)>()? {
            (opt, initial_indent) if opt == atom::initial_indent() => {
                options.initial_indent = initial_indent.decode()?;
            }
            (opt, subsequent_indent) if opt == atom::subsequent_indent() => {
                options.subsequent_indent = subsequent_indent.decode()?;
            }
            (opt, break_words) if opt == atom::break_words() => {
                options.break_words = break_words.decode()?;
            }
            (opt, wrap_algorithm) if opt == atom::wrap_algorithm() => {
                options.wrap_algorithm = wrap_algorithm::wrap_algorithm_from_term(wrap_algorithm)?;
            }
            (opt, splitter) if opt == atom::splitter() || opt == atom::word_splitter() => {
                let splitter: Atom = splitter.decode()?;
                if splitter == false_() {
                    options.word_splitter = WordSplitter::NoHyphenation;
                } else if splitter == nil() {
                    options.word_splitter = WordSplitter::HyphenSplitter;
                } else if splitter == atom::en_us() {
                    let dictionary = Standard::from_embedded(Language::EnglishUS).unwrap();
                    options.word_splitter = WordSplitter::Hyphenation(dictionary);
                } else {
                    return Err(Error::BadArg);
                }
            }
            _ => {}
        };
    }

    Ok(options)
}

rustler::init!("Elixir.Textwrap");
