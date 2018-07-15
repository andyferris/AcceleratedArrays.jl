@testset "SortIndex" begin
    a = [3.0, 2.0, 8.0, 2.0]
    b = accelerate(a, SortIndex)

    @test issetequal(findall(isequal(1.0), b), [])
    @test issetequal(findall(isequal(3.0), b), [1])
    @test issetequal(findall(isequal(2.0), b), [2, 4])

    @test filter(isequal(1.0), b) == []
    @test filter(isequal(3.0), b) == [3.0]
    @test filter(isequal(2.0), b) == [2.0, 2.0]
end