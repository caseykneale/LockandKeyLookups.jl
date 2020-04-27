# LockandKeyLookups

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://caseykneale.github.io/LockandKeyLookups.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://caseykneale.github.io/LockandKeyLookups.jl/dev)
[![Build Status](https://travis-ci.com/caseykneale/LockandKeyLookups.jl.svg?branch=master)](https://travis-ci.com/caseykneale/LockandKeyLookups.jl)
[![Codecov](https://codecov.io/gh/caseykneale/LockandKeyLookups.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/caseykneale/LockandKeyLookups.jl)


Ever have `J` streams of data that, maybe don't fit so well in memory. Well you can lazy load them! But... what if you want to do lookups/labelling tasks with some primary Key in another dataframe(`i` rows long)? Do you really want to run the cost of iterating `i` times to do `J` joins? Probably not - well maybe, but - probably not.

That's where LockandKeyLookups comes into play. LockandKeyLookups are iterators that can be instantiated like the following:
```Julia
lakl = LockandKeyLookup(    key, tumbler,
                            key_lookup_fn, pin_lookup_fn,
                            emitter_fn = ( k, t ) -> k == t)
```

Where the `tumbler` is some array of iterables like `DataFrames`, key is some iterable, and the arguments labelled `_fn` are functions that do the following:
 - `key_lookup_fn` & `pin_lookup_fn` : are the functions used to index the key and tumbler pins for a match condition.
 - `emitter_fn` : is the function used to assess whether the result of the lookup_fn's between a key and a given pin is satisfied.

so we can iterate these instances in for loops, or collections as usual.
```Julia
[ iter for iter in lakl ]
```
where the structure of the `iter` item is the following `( Key_Index[i] => (  Tumbler_Index[J], Pin_Index[Q] ) ) = iter `
So this gives us a mapping between a single key, and a single pin at a time.

![LockAndKeyLookupDiagram](https://raw.githubusercontent.com/caseykneale/LockandKeyLookups.jl/master/Images/locknkey.png)

## Caveats
 - The items must be sorted by the associated key for this to work!
 - Only tested with DataFrames `each(row)` iterables so far.
 - Might not be the fastest option. But it's not very steppy, and should work with lazy iterators.
