@testset "SortIndex" begin
    a = [3.0, 2.0, 8.0, 3.0]
    b = accelerate(a, SortIndex)

    @test 1.0 ∉ b
    @test 2.0 ∈ b
    @test 3.0 ∈ b
    @test 4.0 ∉ b
    @test 8.0 ∈ b
    @test 9.0 ∉ b

    @test count(isequal(1.0), b) == 0
    @test count(isequal(2.0), b) == 1
    @test count(isequal(3.0), b) == 2
    @test count(isequal(4.0), b) == 0
    @test count(isequal(8.0), b) == 1
    @test count(isequal(9.0), b) == 0

    @test count(isless(1.0), b) == 0
    @test count(isless(2.0), b) == 0
    @test count(isless(3.0), b) == 1
    @test count(isless(4.0), b) == 3
    @test count(isless(8.0), b) == 3
    @test count(isless(9.0), b) == 4

    @test count(islessequal(1.0), b) == 0
    @test count(islessequal(2.0), b) == 1
    @test count(islessequal(3.0), b) == 3
    @test count(islessequal(4.0), b) == 3
    @test count(islessequal(8.0), b) == 4
    @test count(islessequal(9.0), b) == 4

    @test count(isgreater(1.0), b) == 4
    @test count(isgreater(2.0), b) == 3
    @test count(isgreater(3.0), b) == 1
    @test count(isgreater(4.0), b) == 1
    @test count(isgreater(8.0), b) == 0
    @test count(isgreater(9.0), b) == 0

    @test count(isgreaterequal(1.0), b) == 4
    @test count(isgreaterequal(2.0), b) == 4
    @test count(isgreaterequal(3.0), b) == 3
    @test count(isgreaterequal(4.0), b) == 1
    @test count(isgreaterequal(8.0), b) == 1
    @test count(isgreaterequal(9.0), b) == 0

    @test count(in(1.1..1.9), b) == 0
    @test count(in(1.1..2.1), b) == 1
    @test count(in(1.1..3.1), b) == 3
    @test count(in(2.1..3.1), b) == 2

    @test issetequal(findall(isequal(1.0), b), [])
    @test issetequal(findall(isequal(2.0), b), [2])
    @test issetequal(findall(isequal(3.0), b), [1, 4])

    @test issetequal(findall(isless(1.1), b), [])
    @test issetequal(findall(isless(2.0), b), [])
    @test issetequal(findall(isless(2.1), b), [2])
    @test issetequal(findall(isless(3.1), b), [1, 2, 4])
    @test issetequal(findall(isless(8.1), b), [1, 2, 3, 4])

    @test issetequal(findall(islessequal(1.1), b), [])
    @test issetequal(findall(islessequal(2.0), b), [2])
    @test issetequal(findall(islessequal(2.1), b), [2])
    @test issetequal(findall(islessequal(3.1), b), [1, 2, 4])
    @test issetequal(findall(islessequal(8.1), b), [1, 2, 3, 4])

    @test issetequal(findall(isgreater(1.1), b), [1, 2, 3, 4])
    @test issetequal(findall(isgreater(2.0), b), [1, 3, 4])
    @test issetequal(findall(isgreater(2.1), b), [1, 3, 4])
    @test issetequal(findall(isgreater(3.1), b), [3])
    @test issetequal(findall(isgreater(8.1), b), [])

    @test issetequal(findall(isgreaterequal(1.1), b), [1, 2, 3, 4])
    @test issetequal(findall(isgreaterequal(2.0), b), [1, 2, 3, 4])
    @test issetequal(findall(isgreaterequal(2.1), b), [1, 3, 4])
    @test issetequal(findall(isgreaterequal(3.1), b), [3])
    @test issetequal(findall(isgreaterequal(8.1), b), [])

    @test issetequal(findall(in(1.1..1.9), b), [])
    @test issetequal(findall(in(1.1..2.1), b), [2])
    @test issetequal(findall(in(1.1..3.1), b), [1, 2, 4])
    @test issetequal(findall(in(2.1..3.1), b), [1, 4])

    @test filter(isequal(1.0), b) == []
    @test filter(isequal(2.0), b) == [2.0]
    @test filter(isequal(3.0), b) == [3.0, 3.0]

    @test issetequal(filter(isless(1.1), b), [])
    @test issetequal(filter(isless(2.0), b), [])
    @test issetequal(filter(isless(2.1), b), [2.0])
    @test issetequal(filter(isless(3.1), b), [2.0, 3.0, 3.0])
    @test issetequal(filter(isless(8.1), b), [2.0, 3.0, 3.0, 8.0])

    @test issetequal(filter(islessequal(1.1), b), [])
    @test issetequal(filter(islessequal(2.0), b), [2.0])
    @test issetequal(filter(islessequal(2.1), b), [2.0])
    @test issetequal(filter(islessequal(3.1), b), [2.0, 3.0, 3.0])
    @test issetequal(filter(islessequal(8.1), b), [2.0, 3.0, 3.0, 8.0])

    @test issetequal(filter(isgreater(1.1), b), [2.0, 3.0, 3.0, 8.0])
    @test issetequal(filter(isgreater(2.0), b), [3.0, 3.0, 8.0])
    @test issetequal(filter(isgreater(2.1), b), [3.0, 3.0, 8.0])
    @test issetequal(filter(isgreater(3.1), b), [8.0])
    @test issetequal(filter(isgreater(8.1), b), [])

    @test issetequal(filter(isgreaterequal(1.1), b), [2.0, 3.0, 3.0, 8.0])
    @test issetequal(filter(isgreaterequal(2.0), b), [2.0, 3.0, 3.0, 8.0])
    @test issetequal(filter(isgreaterequal(2.1), b), [3.0, 3.0, 8.0])
    @test issetequal(filter(isgreaterequal(3.1), b), [8.0])
    @test issetequal(filter(isgreaterequal(8.1), b), [])

    @test issetequal(filter(in(1.1..1.9), b), [])
    @test issetequal(filter(in(1.1..2.1), b), [2.0])
    @test issetequal(filter(in(1.1..3.1), b), [2.0, 3.0, 3.0])
    @test issetequal(filter(in(2.1..3.1), b), [3.0, 3.0])

    @test unique(b)::AcceleratedArray{<:Any,<:Any,<:Any,<:UniqueSortIndex{<:LinearIndices}} == [2.0, 3.0, 8.0]

    @test issetequal(innerjoin(identity, identity, tuple, isequal, b, [1.5, 3.0, 8.0]),
                     innerjoin(identity, identity, tuple, isequal, a, [1.5, 3.0, 8.0]))

    c = accelerate!(a, SortIndex) # a = [2.0, 3.0, 3.0, 8.0]

    @test 1.0 ∉ c
    @test 2.0 ∈ c
    @test 3.0 ∈ c
    @test 4.0 ∉ c
    @test 8.0 ∈ c
    @test 9.0 ∉ c

    @test count(isequal(1.0), c) == 0
    @test count(isequal(2.0), c) == 1
    @test count(isequal(3.0), c) == 2
    @test count(isequal(4.0), c) == 0
    @test count(isequal(8.0), c) == 1
    @test count(isequal(9.0), c) == 0

    @test count(isless(1.0), c) == 0
    @test count(isless(2.0), c) == 0
    @test count(isless(3.0), c) == 1
    @test count(isless(4.0), c) == 3
    @test count(isless(8.0), c) == 3
    @test count(isless(9.0), c) == 4

    @test count(islessequal(1.0), c) == 0
    @test count(islessequal(2.0), c) == 1
    @test count(islessequal(3.0), c) == 3
    @test count(islessequal(4.0), c) == 3
    @test count(islessequal(8.0), c) == 4
    @test count(islessequal(9.0), c) == 4

    @test count(isgreater(1.0), c) == 4
    @test count(isgreater(2.0), c) == 3
    @test count(isgreater(3.0), c) == 1
    @test count(isgreater(4.0), c) == 1
    @test count(isgreater(8.0), c) == 0
    @test count(isgreater(9.0), c) == 0

    @test count(isgreaterequal(1.0), c) == 4
    @test count(isgreaterequal(2.0), c) == 4
    @test count(isgreaterequal(3.0), c) == 3
    @test count(isgreaterequal(4.0), c) == 1
    @test count(isgreaterequal(8.0), c) == 1
    @test count(isgreaterequal(9.0), c) == 0

    @test count(in(1.1..1.9), c) == 0
    @test count(in(1.1..2.1), c) == 1
    @test count(in(1.1..3.1), c) == 3
    @test count(in(2.1..3.1), c) == 2

    @test issetequal(findall(isequal(1.0), c), [])
    @test issetequal(findall(isequal(2.0), c), [1])
    @test issetequal(findall(isequal(3.0), c), [2, 3])

    @test issetequal(findall(isless(1.1), c), [])
    @test issetequal(findall(isless(2.0), c), [])
    @test issetequal(findall(isless(2.1), c), [1])
    @test issetequal(findall(isless(3.1), c), [1, 2, 3])
    @test issetequal(findall(isless(8.1), c), [1, 2, 3, 4])

    @test issetequal(findall(islessequal(1.1), c), [])
    @test issetequal(findall(islessequal(2.0), c), [1])
    @test issetequal(findall(islessequal(2.1), c), [1])
    @test issetequal(findall(islessequal(3.1), c), [1, 2, 3])
    @test issetequal(findall(islessequal(8.1), c), [1, 2, 3, 4])

    @test issetequal(findall(isgreater(1.1), c), [1, 2, 3, 4])
    @test issetequal(findall(isgreater(2.0), c), [2, 3, 4])
    @test issetequal(findall(isgreater(2.1), c), [2, 3, 4])
    @test issetequal(findall(isgreater(3.1), c), [4])
    @test issetequal(findall(isgreater(8.1), c), [])

    @test issetequal(findall(isgreaterequal(1.1), c), [1, 2, 3, 4])
    @test issetequal(findall(isgreaterequal(2.0), c), [1, 2, 3, 4])
    @test issetequal(findall(isgreaterequal(2.1), c), [2, 3, 4])
    @test issetequal(findall(isgreaterequal(3.1), c), [4])
    @test issetequal(findall(isgreaterequal(8.1), c), [])

    @test issetequal(findall(in(1.1..1.9), c), [])
    @test issetequal(findall(in(1.1..2.1), c), [1])
    @test issetequal(findall(in(1.1..3.1), c), [1, 2, 3])
    @test issetequal(findall(in(2.1..3.1), c), [2, 3])

    @test filter(isequal(1.0), c) == []
    @test filter(isequal(2.0), c) == [2.0]
    @test filter(isequal(3.0), c) == [3.0, 3.0]

    @test issetequal(filter(isless(1.1), c), [])
    @test issetequal(filter(isless(2.0), c), [])
    @test issetequal(filter(isless(2.1), c), [2.0])
    @test issetequal(filter(isless(3.1), c), [2.0, 3.0, 3.0])
    @test issetequal(filter(isless(8.1), c), [2.0, 3.0, 3.0, 8.0])

    @test issetequal(filter(islessequal(1.1), c), [])
    @test issetequal(filter(islessequal(2.0), c), [2.0])
    @test issetequal(filter(islessequal(2.1), c), [2.0])
    @test issetequal(filter(islessequal(3.1), c), [2.0, 3.0, 3.0])
    @test issetequal(filter(islessequal(8.1), c), [2.0, 3.0, 3.0, 8.0])

    @test issetequal(filter(isgreater(1.1), c), [2.0, 3.0, 3.0, 8.0])
    @test issetequal(filter(isgreater(2.0), c), [3.0, 3.0, 8.0])
    @test issetequal(filter(isgreater(2.1), c), [3.0, 3.0, 8.0])
    @test issetequal(filter(isgreater(3.1), c), [8.0])
    @test issetequal(filter(isgreater(8.1), c), [])

    @test issetequal(filter(isgreaterequal(1.1), c), [2.0, 3.0, 3.0, 8.0])
    @test issetequal(filter(isgreaterequal(2.0), c), [2.0, 3.0, 3.0, 8.0])
    @test issetequal(filter(isgreaterequal(2.1), c), [3.0, 3.0, 8.0])
    @test issetequal(filter(isgreaterequal(3.1), c), [8.0])
    @test issetequal(filter(isgreaterequal(8.1), c), [])

    @test issetequal(filter(in(1.1..1.9), c), [])
    @test issetequal(filter(in(1.1..2.1), c), [2.0])
    @test issetequal(filter(in(1.1..3.1), c), [2.0, 3.0, 3.0])
    @test issetequal(filter(in(2.1..3.1), c), [3.0, 3.0])

    @test issetequal(innerjoin(identity, identity, tuple, isequal, c, [1.5, 3.0, 8.0]),
                     innerjoin(identity, identity, tuple, isequal, a, [1.5, 3.0, 8.0]))
end