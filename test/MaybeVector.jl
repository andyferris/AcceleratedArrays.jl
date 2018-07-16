@testset "MaybeVector" begin
    a = MaybeVector{Int}()
    @test length(a) == 0

    b = MaybeVector(3)
    @test length(b) == 1
    @test b[1] == 3
end