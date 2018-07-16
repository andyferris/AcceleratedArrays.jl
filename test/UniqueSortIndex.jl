@testset "UniqueSortIndex" begin
    a = [3.0, 2.0, 8.0, 5.0]
    b = accelerate(a, UniqueSortIndex)

    @test findall(isequal(1.0), b)::MaybeVector == []
    @test findall(isequal(8.0), b)::MaybeVector == [3]
    @test findall(isequal(2.0), b)::MaybeVector == [2]

    @test findall(isless(1.1), b) == []
    @test findall(isless(2.1), b) == [2]
    @test issetequal(findall(isless(3.1), b), [1, 2])

    @test filter(isequal(1.0), b)::MaybeVector == []
    @test filter(isequal(8.0), b)::MaybeVector == [8.0]
    @test filter(isequal(2.0), b)::MaybeVector == [2.0]

    @test filter(isless(1.1), b) == []
    @test filter(isless(2.1), b) == [2.0]
    @test issetequal(filter(isless(3.1), b), [2.0, 3.0])

    c = accelerate!(a, UniqueSortIndex) # a = [2.0, 3.0, 5.0, 8.0]

    @test findall(isequal(1.0), c)::MaybeVector == []
    @test findall(isequal(8.0), c)::MaybeVector == [4]
    @test findall(isequal(2.0), c)::MaybeVector == [1]

    @test findall(isless(1.1), c) == []
    @test findall(isless(2.1), c) == [1]
    @test issetequal(findall(isless(3.1), c), [1, 2])

    @test filter(isequal(1.0), c)::MaybeVector == []
    @test filter(isequal(8.0), c)::MaybeVector == [8.0]
    @test filter(isequal(2.0), c)::MaybeVector == [2.0]

    @test filter(isless(1.1), c) == []
    @test filter(isless(2.1), c) == [2.0]
    @test issetequal(filter(isless(3.1), c), [2.0, 3.0])
end