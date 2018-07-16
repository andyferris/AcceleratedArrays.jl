@testset "SortIndex" begin
    a = [3.0, 2.0, 8.0, 3.0]
    b = accelerate(a, SortIndex)

    @test issetequal(findall(isequal(1.0), b), [])
    @test issetequal(findall(isequal(2.0), b), [2])
    @test issetequal(findall(isequal(3.0), b), [1, 4])

    @test issetequal(findall(isless(1.1), b), [])
    @test issetequal(findall(isless(2.1), b), [2])
    @test issetequal(findall(isless(3.1), b), [1, 2, 4])

    @test filter(isequal(1.0), b) == []
    @test filter(isequal(2.0), b) == [2.0]
    @test filter(isequal(3.0), b) == [3.0, 3.0]

    @test issetequal(filter(isless(1.1), b), [])
    @test issetequal(filter(isless(2.1), b), [2.0])
    @test issetequal(filter(isless(3.1), b), [2.0, 3.0, 3.0])

    c = accelerate!(a, SortIndex) # a = [2.0, 3.0, 3.0, 8.0]
    @test issetequal(findall(isequal(1.0), c), [])
    @test issetequal(findall(isequal(2.0), c), [1])
    @test issetequal(findall(isequal(3.0), c), [2, 3])

    @test issetequal(findall(isless(1.1), c), [])
    @test issetequal(findall(isless(2.1), c), [1])
    @test issetequal(findall(isless(3.1), c), [1, 2, 3])

    @test filter(isequal(1.0), c) == []
    @test filter(isequal(2.0), c) == [2.0]
    @test filter(isequal(3.0), c) == [3.0, 3.0]

    @test issetequal(filter(isless(1.1), c), [])
    @test issetequal(filter(isless(2.1), c), [2.0])
    @test issetequal(filter(isless(3.1), c), [2.0, 3.0, 3.0])
end