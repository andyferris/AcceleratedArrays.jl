module AcceleratedArrays

using SplitApplyCombine

using Base: @propagate_inbounds, Fix2, promote_op

export accelerate, accelerate!
export AcceleratedArray, AcceleratedVector, AcceleratedMatrix, MaybeVector
export AbstractIndex, AbstractUniqueIndex, HashIndex, UniqueHashIndex, SortIndex, UniqueSortIndex
export islessequal, isgreater, isgreaterequal

include("predicates.jl") # Add some predicates that are "missing" from Base
include("MaybeVector.jl")
include("Interval.jl")

include("AbstractIndex.jl")
include("AcceleratedArray.jl")
include("UniqueIndex.jl")
include("HashIndex.jl")
include("UniqueHashIndex.jl")
include("SortIndex.jl")
include("UniqueSortIndex.jl")

include("spatialindex.jl")

#= Base functionality =#
#=
function Base.setindex(a::AbstractVector{T}, v::T, i::Int) where {T}
	out = similar(a)
	@inbounds for ind in keys(a)
        out[ind] = ifelse(ind == i, v, a[ind])
	end
    return out
end

Base.setindex(a::AbstractVector{T}, v, i::Int) where {T} = setindex(a, convert(T, v), i)

import Base.setindex
=#
import Base.setindex

end # module

# TODO
#
# * Deal with <, ==, NaN, -0.0, missing, etc?
# * findfirst, findlast, findnext, findprev (requires stable sort?)
# * findmin, findmax (different behavior w.r.t NaN and missing?)
# * group, groupview, groupinds, groupreduce
# * leftgroupjoin