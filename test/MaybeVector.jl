@testset "MaybeVector" begin
    a = MaybeVector{Int}()
    @test length(a) == 0
    @test_throws BoundsError a[1]

    b = MaybeVector(3)
    @test length(b) == 1
    @test b[1] == 3
    @test b[] == 3
    @test_throws BoundsError b[2]
end