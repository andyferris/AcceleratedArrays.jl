@testset "SingleVector" begin
    a = SingleVector(3)
    @test length(a) == 1
    @test a[1] == 3
    @test a[] == 3
    @test_throws BoundsError a[2]
end