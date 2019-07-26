using Test
using AcceleratedArrays
using SplitApplyCombine

@test isempty(detect_ambiguities(Base, AcceleratedArrays))

@testset "AcceleratedArrays" begin
    include("Interval.jl")
    include("MaybeVector.jl")
    include("SingleVector.jl")

    include("HashIndex.jl")
    include("UniqueHashIndex.jl")
    include("SortIndex.jl")
    include("UniqueSortIndex.jl")
end
