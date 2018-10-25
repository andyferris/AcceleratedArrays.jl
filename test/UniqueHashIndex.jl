@testset "UniqueHashIndex" begin
    @test_throws ErrorException accelerate([3, 1, 2, 1], UniqueHashIndex)

    a = UInt[3, 1, 2]
    b = accelerate(a, UniqueHashIndex)

    @test 3 ∈ b
    @test 4 ∉ b

    @test count(isequal(3), b) == 1
    @test count(isequal(4), b) == 0

    @test findall(isequal(1), b)::MaybeVector{Int} == [2]
    @test findall(isequal(4), b)::MaybeVector{Int} == []

    @test filter(isequal(1), b)::MaybeVector{UInt} == [1]
    @test filter(isequal(4), b)::MaybeVector{UInt} == []

    @test unique(b) === b

    @test group(iseven, b) == group(iseven, a)
    @test groupinds(iseven, b) == groupinds(iseven, a)
    @test groupreduce(iseven, +, b) == groupreduce(iseven, +, a)

    @test issetequal(innerjoin(identity, identity, tuple, isequal, b, [0, 1, 2]),
                     innerjoin(identity, identity, tuple, isequal, a, [0, 1, 2]))
end