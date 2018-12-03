module AcceleratedArrays

using SplitApplyCombine

using Base: @propagate_inbounds, Fix2, promote_op

export accelerate, accelerate!
export AcceleratedArray, AcceleratedVector, AcceleratedMatrix, MaybeVector, SingleVector
export AbstractIndex, AbstractUniqueIndex, HashIndex, UniqueHashIndex, SortIndex, UniqueSortIndex
export islessequal, isgreater, isgreaterequal

include("predicates.jl") # Add some predicates that are "missing" from Base
include("MaybeVector.jl")
include("SingleVector.jl")
include("Interval.jl")

include("AbstractIndex.jl")
include("AcceleratedArray.jl")
include("UniqueIndex.jl")
include("UniqueHashIndex.jl")
include("HashIndex.jl")
include("UniqueSortIndex.jl")
include("SortIndex.jl")

end # module

# TODO
#
# * Deal with <, ==, NaN, -0.0, missing, etc?
# * findfirst, findlast, findnext, findprev (requires stable sort?)
# * findmin, findmax (different behavior w.r.t NaN and missing?)
# * group, groupview, groupinds, groupreduce
# * leftgroupjoin, innerjoin, etc