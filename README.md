# AcceleratedArrays.jl

*Arrays with acceleration indices.*

This package provides (secondary) acceleration indexes for Julia `AbstractArray`s. Such
acceleration indexes can be used to speed up certain operations, particularly those
involving searching through the values - for example, an `AcceleratedArray` may have more
efficient implementations of functions such as `findall`, `filter`, and `unique`.

As a general rule, this package has been implemented for the purposes of accelerating
analytics workloads and is designed to support functional, non-mutating workflows. It is
currently not supported to add an index to data you expect to mutate afterwards.

## Getting started

To start using this package, from Julia v0.7 type:

```julia
Pkg.develop("https://github.com/andyferris/AcceleratedArrays.jl")
using AcceleratedArrays
```

An `AcceleratedArray` is generally created by using the `accelerate` and `accelerate!`
functions. 

```julia
# Construct a hash mapping to unique names
a = accelerate(["Alice", "Bob", "Charlie"], UniqueHashIndex)

# Rearrange an array of random numbers into ascending order
b = accelerate!(rand(1:100, 100),)
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

### Suported Indexes

#### `HashIndex`

This index constructs a hashmap between values in the array, and the corresponding array
indices. For example, invoking `findall` to search for the locations of certain values
will be reduced to a simple dictionary lookup.

#### `UniqueHashIndex`

Like `HashIndex`, except each value in the array will only appear once. Apart from
guaranteeing uniqueness, certain operations may be faster with a `UniqueHashIndex` than 
with a `HashIndex`.

#### `SortIndex`

This index determines the order of the elements (with respect to `isless`).

The `accelerate!` function will rearrange the input array, like `sort!`. This can speed
up operations due to simplified algorithms and cache locality.

#### `UniqueSortIndex`

Like `SortIndex`, except each value in the array will only appear once. Apart from
guaranteeing uniqueness, certain operations may be faster with a `UniqueSortIndex` than 
with a `SortIndex`.

#### Work remaining

 * Support more functions, including those in `SplitApplyCombine`.
 * Figure out how to supprt `missing`, `==`, `<`, etc.
 * Possibly more indices like some kind of spatial index (KDTree or whatever - problem
   is we require the predicates too, but we don't have the language for that).
 
