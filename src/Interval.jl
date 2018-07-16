# IntervalSets.jl currently has deprecation warnings on Julia 0.7

export Interval, ..

abstract type AbstractInterval{T}; end

"""
    Interval(start, stop)

Construct a closed interval, which is a collection which contains (via `in`) elements
between `start` and `stop` (inclusive) according to `isless`. The collection is abstract
in nature and doesn't support iteration, indexing, etc.

Can be constructed via the `..` function, e.g. `1..3 === Interval(1, 3)`.

# Examples

```julia
julia> 2 in Interval(1, 3)
true

julia> 3 in Interval(1, 3)
true

julia> 4 in Interval(1, 3)
false
"""
struct Interval{T} <: AbstractInterval{T}
    start::T
    stop::T
end

"""
    ..(start, stop)
    start..stop

Constructs an `Interval(start, stop)`, which represents the closed interval between `start`
and `stop`. `Interval`s are abstract collections which support `in` but not iteration,
indexing, etc.

# Examples

```julia
julia> 2 in 1..3
true

julia> 3 in 1..3
true

julia> 4 in 1..3
false
"""
..(start::T, stop::T) where {T} = Interval{T}(start, stop)
..(start, stop) = ..(promote(start, stop)...)

function Base.in(x::T, interval::Interval{T}) where {T}
    return !isless(x, interval.start) && !isless(interval.stop, x)
end

function Base.in(x, interval::Interval{T}) where {T}
    return !isless(promote(x, interval.start)...) && !isless(promote(interval.stop, x)...)
end

function Base.:(==)(i1::Interval, i2::Interval)
    (isequal(i1.start, i2.start) && isequal(i1.stop, i2.stop)) || isless(i1.stop, i2.start)
end

function Base.isequal(i1::Interval, i2::Interval)
    isequal(i1.start, i2.start) && isequal(i1.stop, i2.stop)
end

function Base.isless(i1::Interval, i2::Interval)
    isless(i1.start, i2.start) || (isequal(i1.start, i2.start) && isless(i1.stop, i2.stop))
end

Base.hash(interval::Interval, h) = hash(hash(interval.start, h), interval.stop)

function Base.show(io::IO, interval::Interval)
    print(io, interval.start)
    print(io, "..")
    print(io, interval.stop)
end
