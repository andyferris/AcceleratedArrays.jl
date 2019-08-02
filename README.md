# AcceleratedArrays.jl

*Arrays with acceleration indices.*

[![Build Status](https://travis-ci.org/andyferris/AcceleratedArrays.jl.svg?branch=master)](https://travis-ci.org/andyferris/AcceleratedArrays.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/9qwb219wpdm3dg3c?svg=true)](https://ci.appveyor.com/project/andyferris/acceleratedarrays-jl)
[![codecov](https://codecov.io/gh/andyferris/AcceleratedArrays.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/andyferris/AcceleratedArrays.jl)

**AcceleratedArrays** provides (secondary) acceleration indexes for Julia `AbstractArray`s. Such
acceleration indexes can be used to speed up certain operations, particularly those
involving searching through the values - for example, an `AcceleratedArray` may have more
efficient implementations of functions such as `findall`, `filter`, and `unique`.

As a general rule, this package has been implemented for the purposes of accelerating
analytics workloads and is designed to support functional, non-mutating workflows. It is
currently not supported to add an index to data you expect to mutate afterwards.

## Getting started

To download this package, from Julia v1.0 press `]` to enter package mode and type:

```julia
pkg> dev https://github.com/andyferris/AcceleratedArrays.jl
```

An `AcceleratedArray` is generally created by using the `accelerate` and `accelerate!`
functions. 

```julia
# Construct a hash mapping to unique names
a = accelerate(["Alice", "Bob", "Charlie"], UniqueHashIndex)

# Rearrange an array of random numbers into ascending order
b = accelerate!(rand(1:100, 100), SortIndex)
```

The resulting arrays can be used just like regular Julia arrays, except some operations
become faster. For example, the hash map will let us find a certain element without
exhaustively searching the array, or we can easily find all the elements within a
given interval with a sorted array.

```julia
# Find the index of "Bob" in `a`
findall(isequal("Bob"), a)

# Return all the numbers in `b` between 40 and 60
filter(in(40..60), b)
```
## Accelerated functions

Accelerations are fully implemented for the following functions, where `a` is an
`AcceleratedArray`:

 * `x ∈ a`
 * `count(pred, a)`
 * `findall(pred, a)`
 * `filter(pred, a)`

There is some work-in-progress on a variety of other functions, including some from
[SplitApplyCombine](https://github.com/JuliaData/SplitApplyCombine.jl):

 * `findfirst(pred, a)` and `findlast(pred, a)`
 * `unique(a)`
 * `group`, `groupinds`, `groupview` and `groupreduce`
 * `innerjoin`

Accelerations are only available for some predicates `pred`, which naturally depend on the
acceleration index used (see below for a full set).

## Acceleration Indexes

The package intruduces the `AbstractIndex` supertype and the following concrete implemetations.
Generally, an index is created when the user calls `accelerate` or `accelerate!`.

#### `HashIndex`

This index constructs a hashmap between values in the array, and the corresponding array
indices. For example, invoking `findall` to search for the locations of certain values
will be reduced to a simple dictionary lookup. Primarily accelerates commands using the
`isequal` predicate.

#### `UniqueHashIndex`

Like `HashIndex`, except each value in the array can only appear once. Apart from
guaranteeing uniqueness, certain operations may be faster with a `UniqueHashIndex` than 
with a `HashIndex`.

#### `SortIndex`

This index determines the order of the elements (with respect to `isless`). This index
can accelerate not only the `isequal` predicate, but a variety of other order-based
predicates as well (see below).

The `accelerate!` function will rearrange the input array, like `sort!`. This can speed
up operations due to simplified algorithms and cache locality.

#### `UniqueSortIndex`

Like `SortIndex`, except each value in the array can only appear once. Apart from
guaranteeing uniqueness, certain operations may be faster with a `UniqueSortIndex` than 
with a `SortIndex`.

### Custom acceleration indices

It is simple for a user or another package to implement an `AbstractIndex` - for instance
a third-party package may provide a spatial acceleration index, or an index for fast
textual search. Simply overload `accelerate` (and optionally `accelerate!`) as well as the
operations you would like to accelerate, such as `filter`, `findall`, etc. Indices for
unique sets of values may inherit from `AbstractUniqueIndex <: AbstractIndex`.

## Order-based predicates and Intervals

In Julia, sorting is (typically) achieved using the `isless` and `isequal` predicates,
which are designed to provide a canonical total order for values. Currently, the
acceleration indices rely on these rather than the comparison operators `==`, `<`, `<=`,
`>`, `>=` and `!=`.

To make life easier, this package introduces a number of new convenience functions:

 * `islessequal(a, b) = isless(a, b) || isequal(a, b)`
 * `isgreater(a, b) = isless(b, a)`
 * `isgreaterequal(a, b) = isless(b, a) || isequal(a, b)`

Any of these support "currying", which is a simple syntax for creating a closure such as
`isequal(a) = (b -> isequal(a, b))`. Such curried predicates are picked up by multiple
dispatch to accelerate operations like `findall(isequal(3.0), accelerated_array)`.

### Intervals

It is common to want to search for all values in a range. This package introduces an
`Interval` type to represent the set of of values between two endpoints (with respect to
`isless` and `isequal`).

An interval is easily created with the `..` operator via the syntax `a .. b`. To find if
a value is in this range, use the `in` function/operator (alternatively spelled `∈`, which
can be inserted at the REPL via `\in <TAB>`). For example, `3 ∈ 0 .. 10` is `true` but
`13 ∈ 0 .. 10` is `false`.

By default, an interval is inclusive of its endpoints, such that `10 ∈ 0 .. 10`. An endpoint
can be excluded via the `lessthan` or `greaterthan` function, which returns a value almost equal
to but slightly less/greater than its input. An interval exclusive of both its endpoints can be
expressed as `greaterthan(a) .. lessthan(b)`. For example `10 ∉ 0 .. lessthan(10)`.

## Work remaining

This package is still young, and could support some more features, such as:

 * Accelerate more functions, including those in `SplitApplyCombine`.
 * Figure out how to support `missing`, `==`, `<` with either a hash- or sort-based index.
 * Move `Interval`s into their own package, potentially reconcile with *IntervalSets.jl*
   (which currently uses `<=` and `>=` for comparisons).
