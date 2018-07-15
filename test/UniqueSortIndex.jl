@testset "UniqueSortIndex" begin
    a = [3.0, 2.0, 8.0, 5.0]
    b = accelerate(a, UniqueSortIndex)

    @test findall(isequal(1.0), b)::MaybeVector == []
    @test findall(isequal(8.0), b)::MaybeVector == [3]
    @test findall(isequal(2.0), b)::MaybeVector == [2]

    @test filter(isequal(1.0), b)::MaybeVector == []
    @test filter(isequal(8.0), b)::MaybeVector == [8.0]
    @test filter(isequal(2.0), b)::MaybeVector == [2.0]
end