use rustler::types::Atom;
use rustler::{Error, NifResult, Term};
use textwrap::{wrap_algorithms::Penalties, WrapAlgorithm};

use crate::atom;

pub(crate) fn wrap_algorithm_from_term(term: Term) -> NifResult<WrapAlgorithm> {
    // Try to decode as atom first
    if let Ok(algo_atom) = term.decode::<Atom>() {
        if algo_atom == atom::first_fit() {
            return Ok(WrapAlgorithm::FirstFit);
        } else if algo_atom == atom::optimal_fit() {
            return Ok(WrapAlgorithm::OptimalFit(Penalties::default()));
        } else {
            return Err(Error::BadArg);
        }
    }

    // Try to decode as tuple
    if let Ok((algo_atom, penalties_map)) = term.decode::<(Atom, Term)>() {
        if algo_atom == atom::optimal_fit() {
            let penalties = penalties_from_map(penalties_map)?;
            return Ok(WrapAlgorithm::OptimalFit(penalties));
        } else {
            return Err(Error::BadArg);
        }
    }

    Err(Error::BadArg)
}

fn penalties_from_map(penalties_map: Term) -> NifResult<Penalties> {
    let mut penalties = Penalties::default();

    let map_iter: rustler::types::map::MapIterator = penalties_map.decode()?;

    for (key, value) in map_iter {
        let key_atom: Atom = key.decode()?;
        let val: usize = value.decode()?;

        if key_atom == atom::nline_penalty() {
            penalties.nline_penalty = val;
        } else if key_atom == atom::overflow_penalty() {
            penalties.overflow_penalty = val;
        } else if key_atom == atom::short_last_line_fraction() {
            penalties.short_last_line_fraction = val;
        } else if key_atom == atom::short_last_line_penalty() {
            penalties.short_last_line_penalty = val;
        } else if key_atom == atom::hyphen_penalty() {
            penalties.hyphen_penalty = val;
        }
    }

    Ok(penalties)
}
