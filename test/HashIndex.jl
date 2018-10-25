@testset "HashIndex" begin
   a = [3, 1, 2, 1]
   b = accelerate(a, HashIndex)
   
   @test 2 ∈ b
   @test 0 ∉ b

   @test count(isequal(1), b) == 2
   @test count(isequal(2), b) == 1
   @test count(isequal(4), b) == 0
   
   @test findall(isequal(1), b) == [2, 4]
   @test findall(isequal(4), b) == []

   @test filter(isequal(1), b) == [1, 1]
   @test filter(isequal(4), b) == []

   @test issetequal(unique(b), [1,2,3])

   @test group(identity, b) == group(identity, a)
   @test groupinds(identity, b) == groupinds(identity, a)
   @test groupreduce(identity, +, b) == groupreduce(identity, +, a)

   @test issetequal(innerjoin(identity, identity, tuple, isequal, b, [0, 1, 2]),
                    innerjoin(identity, identity, tuple, isequal, a, [0, 1, 2]))
end