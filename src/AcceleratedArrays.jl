module AcceleratedArrays

using Base: @propagate_inbounds, Fix2

export accelerate, accelerate!
export AcceleratedArray, AcceleratedVector, AcceleratedMatrix, MaybeVector
export AbstractIndex, AbstractUniqueIndex, HashIndex, UniqueHashIndex, SortIndex, UniqueSortIndex

include("MaybeVector.jl")

include("AbstractIndex.jl")
include("AcceleratedArray.jl")
include("UniqueIndex.jl")
include("HashIndex.jl")
include("UniqueHashIndex.jl")
include("SortIndex.jl")
include("UniqueSortIndex.jl")

end # module
