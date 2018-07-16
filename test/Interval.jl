@testset "Interval" begin
    @test 0..1 isa Interval
    interval = 0..1
    
    @test 0 ∈ interval
    @test 1 ∈ interval
    @test 2 ∉ interval
    @test -1 ∉ interval
    @test 0.5 ∈ interval
    @test 1.1 ∉ interval
    @test -0.1 ∉ interval
end
