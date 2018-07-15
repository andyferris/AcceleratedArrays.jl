@testset "HashIndex" begin
   a = [3, 1, 2, 1]
   b = accelerate(a, HashIndex)
   @test findall(isequal(1), a) == [2, 4]
   @test filter(isequal(1), a) == [1 ,1]
   @test issetequal(unique(b), [1,2,3])
end