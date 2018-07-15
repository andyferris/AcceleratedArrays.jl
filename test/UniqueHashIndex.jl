@testset "UniqueHashIndex" begin
   @test_throws ErrorException accelerate([3.0, 1.0, 2.0, 1.0], UniqueHashIndex)
   
   a = [3.0, 1.0, 2.0]
   b = accelerate(a, UniqueHashIndex)
   @test findall(isequal(1.0), b)::MaybeVector{Int} == [2]
   @test findall(isequal(4.0), b)::MaybeVector{Int} == []
   
   @test filter(isequal(1.0), b)::MaybeVector{Float64} == [1.0]
   @test filter(isequal(4.0), b)::MaybeVector{Float64} == []
   
   @test unique(b) ===  b
end