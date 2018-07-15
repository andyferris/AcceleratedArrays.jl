# AcceleratedArrays.jl

*Arrays with acceleration indices.*

This package provides (seconday) acceleration indexes for Julia `AbstractArray`s. Such
acceleration indexes can be used to speed up certain operations, particularly those
involving searching through the values - for example, an `AcceleratedArray` may have more
efficient implementations of functions such as `findall`, `filter`, and `unique`.

As a general rule, this package has been implemented for the purposes of accelerating
analytics workloads and is designed to support functional, non-mutating workflows. It is
currently not supported to add an index to data you expect to mutate afterwards.

#### `HashIndex`

This index constructs a hashmap between values in the array, and the corresponding array
indices. For example, invoking `findall` to search for the locations of certain values
will be reduced to a simple dictionary lookup.

#### `UniqueHashIndex`

Like `HashIndex`, except each value in the array will only appear once. Apart from
guaranteeing uniqueness, certain operations may be faster with a `UniqueHashIndex` than 
with a `HashIndex`.

#### Work remaining

 * More indices - at least `UniqueIndex`, `SortIndex`, `UniqueSortIndex` and some kind of
   spatial index (KDTree or whatever).
 * Support more functions, including those in `SplitApplyCombine`.
 * Implement `isless(value)`, `<(value)`, `>(value)`, `<=(value)`, `>=value`, `!=(value)`
   via `Fix2`.
 * Support intervals with `..` syntax.
