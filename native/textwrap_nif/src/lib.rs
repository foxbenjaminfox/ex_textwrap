use hyphenation::{Language, Load, Standard};
use rustler::types::{atom::false_, atom::nil, Atom};
use rustler::{Error, ListIterator, NifResult, Term};
use std::borrow::Cow;
use textwrap::core::WrapAlgorithm;
use textwrap::{HyphenSplitter, NoHyphenation, WordSplitter};

mod atom {
    rustler::atoms! {
        break_words,
        initial_indent,
        splitter,
        subsequent_indent,
        wrap_algorithm,

        first_fit,
        optimal_fit,

        en_us,
    }
}

type TextwrapOptions<'a> = textwrap::Options<'a, Box<dyn WordSplitter>>;

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

fn wrap_options<'a>(width: usize, opts: ListIterator<'a>) -> NifResult<TextwrapOptions<'a>> {
    let mut options: TextwrapOptions =
        textwrap::Options::with_splitter(width, Box::new(HyphenSplitter));

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
                let wrap_alorithm: Atom = wrap_algorithm.decode()?;

                if wrap_alorithm == atom::first_fit() {
                    options.wrap_algorithm = WrapAlgorithm::FirstFit;
                } else if wrap_alorithm == atom::optimal_fit() {
                    options.wrap_algorithm = WrapAlgorithm::OptimalFit;
                } else {
                    return Err(Error::BadArg);
                }
            }
            (opt, splitter) if opt == atom::splitter() => {
                let splitter: Atom = splitter.decode()?;
                if splitter == false_() {
                    options.splitter = Box::new(NoHyphenation);
                } else if splitter == nil() {
                    options.splitter = Box::new(HyphenSplitter);
                } else if splitter == atom::en_us() {
                    options.splitter =
                        Box::new(Standard::from_embedded(Language::EnglishUS).unwrap());
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
