module AcceleratedArrays

using Base: @propagate_inbounds, Fix2

export accelerate, accelerate!
export AcceleratedArray, AcceleratedVector, AcceleratedMatrix, MaybeVector
export AbstractIndex, AbstractUniqueIndex, HashIndex, UniqueHashIndex, SortIndex, UniqueSortIndex

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

end # module
