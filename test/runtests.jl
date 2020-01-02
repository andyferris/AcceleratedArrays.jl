using Test
using AcceleratedArrays
using SplitApplyCombine
using Dictionaries

@test isempty(setdiff(detect_ambiguities(Base, AcceleratedArrays, Dictionaries), detect_ambiguities(Base, Dictionaries) ))

@testset "AcceleratedArrays" begin
    include("Interval.jl")
    include("MaybeVector.jl")
    include("SingleVector.jl")

    include("HashIndex.jl")
    include("UniqueHashIndex.jl")
    include("SortIndex.jl")
    include("UniqueSortIndex.jl")
end
