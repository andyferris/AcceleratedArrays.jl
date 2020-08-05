# Helper functions (perhaps something like this could be useful in Base)

# index of the last value of vector a that is less than but not equal to x;
# returns 0 if x is less than all values of v.
function searchsortedlastless(v::AbstractVector, x, lo::Int = first(keys(v)), hi::Int = last(keys(v)))
    lo = lo-1
    hi = hi+1
    @inbounds while lo < hi-1
        m = (lo+hi)>>>1
        y = v[m]
        if isless(y, x)
            lo = m
        else
            hi = m
        end
    end
    return lo
end

function searchsortedfirstgreater(v::AbstractVector, x, lo::Int = first(keys(v)), hi::Int = last(keys(v)))
    lo = lo-1
    hi = hi+1
    @inbounds while lo < hi-1
        m = (lo+hi)>>>1
        if isless(x, v[m])
            hi = m
        else
            lo = m
        end
    end
    return hi
end

# Some predicates which are "missing" from Base

function islessequal(a, b)
    isless(a, b) || isequal(a, b)
end

function isgreater(a, b)
    isless(b, a) || isequal(a, b)
end

function isgreaterequal(a, b)
    isless(b, a) || isequal(a, b)
end


Base.isless(x) = Fix2(isless, x)
islessequal(x) = Fix2(islessequal, x)
isgreater(x) = Fix2(isgreater, x)
isgreaterequal(x) = Fix2(isgreaterequal, x)
if VERSION < v"1.2.0-DEV.257"
    # Added to Base in https://github.com/JuliaLang/julia/pull/30915
    Base.:(<)(x) = Fix2(<, x)
    Base.:(<=)(x) = Fix2(<=, x)
    Base.:(>)(x) = Fix2(>, x)
    Base.:(>=)(x) = Fix2(>=, x)
    Base.:(!=)(x) = Fix2(!=, x)
end

# Search for other things that are == but not isequal (for example -0.0)
other_equal(::Any) = ()
other_equal(x::AbstractFloat) = isequal(x, 0.0) ? MaybeVector(convert(typeof(x), -0.0)) : isequal(x, -0.0) ? MaybeVector(convert(typeof(x), 0.0)) : MaybeVector{typeof(x)}()

# ismissing
Base.count(f::typeof(ismissing), a::AcceleratedArray) = count(isequal(missing), a)
Base.findall(f::typeof(ismissing), a::AcceleratedArray) = findall(isequal(missing), a)
Base.findfirst(f::typeof(ismissing), a::AcceleratedArray) = findfirst(isequal(missing), a)
Base.findlast(f::typeof(ismissing), a::AcceleratedArray) = findlast(isequal(missing), a)
Base.filter(f::typeof(ismissing), a::AcceleratedArray) = filter(isequal(missing), a)

# TODO isnan, iszero, isone, isfinite (all are slightly strange when considering things like Complex, Matrix and String)