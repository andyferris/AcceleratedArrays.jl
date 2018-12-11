@testset "UniqueSortIndex" begin
    a = [3.0, 2.0, 8.0, 5.0]
    b = accelerate(a, UniqueSortIndex)

    @test 1.0 ∉ b
    @test 2.0 ∈ b
    @test 3.0 ∈ b
    @test 4.0 ∉ b
    @test 5.0 ∈ b
    @test 8.0 ∈ b
    @test 9.0 ∉ b

    @test count(isequal(1.0), b) == 0
    @test count(isequal(2.0), b) == 1
    @test count(isequal(3.0), b) == 1
    @test count(isequal(4.0), b) == 0
    @test count(isequal(5.0), b) == 1
    @test count(isequal(8.0), b) == 1
    @test count(isequal(9.0), b) == 0

    @test count(isless(1.1), b) == 0
    @test count(isless(2.0), b) == 0
    @test count(isless(2.1), b) == 1
    @test count(isless(3.1), b) == 2
    @test count(isless(8.1), b) == 4

    @test count(islessequal(1.1), b) == 0
    @test count(islessequal(2.0), b) == 1
    @test count(islessequal(2.1), b) == 1
    @test count(islessequal(3.1), b) == 2
    @test count(islessequal(8.1), b) == 4

    @test count(isgreater(1.1), b) == 4
    @test count(isgreater(2.0), b) == 3
    @test count(isgreater(2.1), b) == 3
    @test count(isgreater(3.1), b) == 2
    @test count(isgreater(8.1), b) == 0

    @test count(isgreaterequal(1.1), b) == 4
    @test count(isgreaterequal(2.0), b) == 4
    @test count(isgreaterequal(2.1), b) == 3
    @test count(isgreaterequal(3.1), b) == 2
    @test count(isgreaterequal(8.1), b) == 0

    @test count(in(1.1..1.9), b) == 0
    @test count(in(1.1..2.1), b) == 1
    @test count(in(1.1..3.1), b) == 2
    @test count(in(2.1..3.1), b) == 1

    @test findall(isequal(1.0), b)::MaybeVector == []
    @test findall(isequal(8.0), b)::MaybeVector == [3]
    @test findall(isequal(2.0), b)::MaybeVector == [2]

    @test issetequal(findall(isless(1.1), b), [])
    @test issetequal(findall(isless(2.0), b), [])
    @test issetequal(findall(isless(2.1), b), [2])
    @test issetequal(findall(isless(3.1), b), [1, 2])
    @test issetequal(findall(isless(8.1), b), [1, 2, 3, 4])

    @test issetequal(findall(islessequal(1.1), b), [])
    @test issetequal(findall(islessequal(2.0), b), [2])
    @test issetequal(findall(islessequal(2.1), b), [2])
    @test issetequal(findall(islessequal(3.1), b), [1, 2])
    @test issetequal(findall(islessequal(8.1), b), [1, 2, 3, 4])

    @test issetequal(findall(isgreater(1.1), b), [1, 2, 3, 4])
    @test issetequal(findall(isgreater(2.0), b), [1, 3, 4])
    @test issetequal(findall(isgreater(2.1), b), [1, 3, 4])
    @test issetequal(findall(isgreater(3.1), b), [3, 4])
    @test issetequal(findall(isgreater(8.1), b), [])

    @test issetequal(findall(isgreaterequal(1.1), b), [1, 2, 3, 4])
    @test issetequal(findall(isgreaterequal(2.0), b), [1, 2, 3, 4])
    @test issetequal(findall(isgreaterequal(2.1), b), [1, 3, 4])
    @test issetequal(findall(isgreaterequal(3.1), b), [3, 4])
    @test issetequal(findall(isgreaterequal(8.1), b), [])

    @test issetequal(findall(in(1.1..1.9), b), [])
    @test issetequal(findall(in(1.1..2.1), b), [2])
    @test issetequal(findall(in(1.1..3.1), b), [1, 2])
    @test issetequal(findall(in(2.1..3.1), b), [1])

    @test findfirst(isequal(1.0), b) === nothing
    @test findfirst(isequal(8.0), b) === 3
    @test findfirst(isequal(2.0), b) === 2

    @test findlast(isequal(1.0), b) === nothing
    @test findlast(isequal(8.0), b) === 3
    @test findlast(isequal(2.0), b) === 2

    @test filter(isequal(1.0), b)::MaybeVector == []
    @test filter(isequal(8.0), b)::MaybeVector == [8.0]
    @test filter(isequal(2.0), b)::MaybeVector == [2.0]

    @test issetequal(filter(isless(1.1), b), [])
    @test issetequal(filter(isless(2.0), b), [])
    @test issetequal(filter(isless(2.1), b), [2.0])
    @test issetequal(filter(isless(3.1), b), [2.0, 3.0])
    @test issetequal(filter(isless(8.1), b), [2.0, 3.0, 5.0, 8.0])

    @test issetequal(filter(islessequal(1.1), b), [])
    @test issetequal(filter(islessequal(2.0), b), [2.0])
    @test issetequal(filter(islessequal(2.1), b), [2.0])
    @test issetequal(filter(islessequal(3.1), b), [2.0, 3.0])
    @test issetequal(filter(islessequal(8.1), b), [2.0, 3.0, 5.0, 8.0])

    @test issetequal(filter(isgreater(1.1), b), [2.0, 3.0, 5.0, 8.0])
    @test issetequal(filter(isgreater(2.0), b), [3.0, 5.0, 8.0])
    @test issetequal(filter(isgreater(2.1), b), [3.0, 5.0, 8.0])
    @test issetequal(filter(isgreater(3.1), b), [5.0, 8.0])
    @test issetequal(filter(isgreater(8.1), b), [])

    @test issetequal(filter(isgreaterequal(1.1), b), [2.0, 3.0, 5.0, 8.0])
    @test issetequal(filter(isgreaterequal(2.0), b), [2.0, 3.0, 5.0, 8.0])
    @test issetequal(filter(isgreaterequal(2.1), b), [3.0, 5.0, 8.0])
    @test issetequal(filter(isgreaterequal(3.1), b), [5.0, 8.0])
    @test issetequal(filter(isgreaterequal(8.1), b), [])

    @test issetequal(filter(in(1.1..1.9), b), [])
    @test issetequal(filter(in(1.1..2.1), b), [2.0])
    @test issetequal(filter(in(1.1..3.1), b), [2.0, 3.0])
    @test issetequal(filter(in(2.1..3.1), b), [3.0])

    @test issetequal(innerjoin(identity, identity, tuple, isequal, b, [1.5, 3.0, 8.0]),
                     innerjoin(identity, identity, tuple, isequal, a, [1.5, 3.0, 8.0]))

    c = accelerate!(a, UniqueSortIndex) # a = [2.0, 3.0, 5.0, 8.0]

    @test 1.0 ∉ c
    @test 2.0 ∈ c
    @test 3.0 ∈ c
    @test 4.0 ∉ c
    @test 5.0 ∈ c
    @test 8.0 ∈ c
    @test 9.0 ∉ c

    @test count(isequal(1.0), c) == 0
    @test count(isequal(2.0), c) == 1
    @test count(isequal(3.0), c) == 1
    @test count(isequal(4.0), c) == 0
    @test count(isequal(5.0), c) == 1
    @test count(isequal(8.0), c) == 1
    @test count(isequal(9.0), c) == 0

    @test count(isless(1.1), c) == 0
    @test count(isless(2.0), c) == 0
    @test count(isless(2.1), c) == 1
    @test count(isless(3.1), c) == 2
    @test count(isless(8.1), c) == 4

    @test count(islessequal(1.1), c) == 0
    @test count(islessequal(2.0), c) == 1
    @test count(islessequal(2.1), c) == 1
    @test count(islessequal(3.1), c) == 2
    @test count(islessequal(8.1), c) == 4

    @test count(isgreater(1.1), c) == 4
    @test count(isgreater(2.0), c) == 3
    @test count(isgreater(2.1), c) == 3
    @test count(isgreater(3.1), c) == 2
    @test count(isgreater(8.1), c) == 0

    @test count(isgreaterequal(1.1), c) == 4
    @test count(isgreaterequal(2.0), c) == 4
    @test count(isgreaterequal(2.1), c) == 3
    @test count(isgreaterequal(3.1), c) == 2
    @test count(isgreaterequal(8.1), c) == 0

    @test count(in(1.1..1.9), c) == 0
    @test count(in(1.1..2.1), c) == 1
    @test count(in(1.1..3.1), c) == 2
    @test count(in(2.1..3.1), c) == 1

    @test findall(isequal(1.0), c)::MaybeVector == []
    @test findall(isequal(8.0), c)::MaybeVector == [4]
    @test findall(isequal(2.0), c)::MaybeVector == [1]

    @test issetequal(findall(isless(1.1), c), [])
    @test issetequal(findall(isless(2.0), c), [])
    @test issetequal(findall(isless(2.1), c), [1])
    @test issetequal(findall(isless(3.1), c), [1, 2])
    @test issetequal(findall(isless(8.1), c), [1, 2, 3, 4])

    @test issetequal(findall(islessequal(1.1), c), [])
    @test issetequal(findall(islessequal(2.0), c), [1])
    @test issetequal(findall(islessequal(2.1), c), [1])
    @test issetequal(findall(islessequal(3.1), c), [1, 2])
    @test issetequal(findall(islessequal(8.1), c), [1, 2, 3, 4])

    @test issetequal(findall(isgreater(1.1), c), [1, 2, 3, 4])
    @test issetequal(findall(isgreater(2.0), c), [2, 3, 4])
    @test issetequal(findall(isgreater(2.1), c), [2, 3, 4])
    @test issetequal(findall(isgreater(3.1), c), [3, 4])
    @test issetequal(findall(isgreater(8.1), c), [])

    @test issetequal(findall(isgreaterequal(1.1), c), [1, 2, 3, 4])
    @test issetequal(findall(isgreaterequal(2.0), c), [1, 2, 3, 4])
    @test issetequal(findall(isgreaterequal(2.1), c), [2, 3, 4])
    @test issetequal(findall(isgreaterequal(3.1), c), [3, 4])
    @test issetequal(findall(isgreaterequal(8.1), c), [])

    @test issetequal(findall(in(1.1..1.9), c), [])
    @test issetequal(findall(in(1.1..2.1), c), [1])
    @test issetequal(findall(in(1.1..3.1), c), [1, 2])
    @test issetequal(findall(in(2.1..3.1), c), [2])

    @test findfirst(isequal(1.0), c) === nothing
    @test findfirst(isequal(8.0), c) === 4
    @test findfirst(isequal(2.0), c) === 1

    @test findfirst(isless(1.1), c) === nothing
    @test findfirst(isless(2.0), c) === nothing
    @test findfirst(isless(2.1), c) === 1
    @test findfirst(isless(3.1), c) === 1
    @test findfirst(isless(8.1), c) === 1

    @test findfirst(islessequal(1.1), c) === nothing
    @test findfirst(islessequal(2.0), c) === 1
    @test findfirst(islessequal(2.1), c) === 1
    @test findfirst(islessequal(3.1), c) === 1
    @test findfirst(islessequal(8.1), c) === 1

    @test findfirst(isgreater(1.1), c) === 1
    @test findfirst(isgreater(2.0), c) === 2
    @test findfirst(isgreater(2.1), c) === 2
    @test findfirst(isgreater(3.1), c) === 3
    @test findfirst(isgreater(8.1), c) === nothing

    @test findfirst(isgreaterequal(1.1), c) === 1
    @test findfirst(isgreaterequal(2.0), c) === 1
    @test findfirst(isgreaterequal(2.1), c) === 2
    @test findfirst(isgreaterequal(3.1), c) === 3
    @test findfirst(isgreaterequal(8.1), c) === nothing

    @test findfirst(in(1.1..1.9), c) === nothing
    @test findfirst(in(1.1..2.1), c) === 1
    @test findfirst(in(1.1..3.1), c) === 1
    @test findfirst(in(2.1..3.1), c) === 2

    @test findlast(isequal(1.0), c) === nothing
    @test findlast(isequal(8.0), c) === 4
    @test findlast(isequal(2.0), c) === 1

    @test findlast(isless(1.1), c) === nothing
    @test findlast(isless(2.0), c) === nothing
    @test findlast(isless(2.1), c) === 1
    @test findlast(isless(3.1), c) === 2
    @test findlast(isless(8.1), c) === 4

    @test findlast(islessequal(1.1), c) === nothing
    @test findlast(islessequal(2.0), c) === 1
    @test findlast(islessequal(2.1), c) === 1
    @test findlast(islessequal(3.1), c) === 2
    @test findlast(islessequal(8.1), c) === 4

    @test findlast(isgreater(1.1), c) === 4
    @test findlast(isgreater(2.0), c) === 4
    @test findlast(isgreater(2.1), c) === 4
    @test findlast(isgreater(3.1), c) === 4
    @test findlast(isgreater(8.1), c) === nothing

    @test findlast(isgreaterequal(1.1), c) === 4
    @test findlast(isgreaterequal(2.0), c) === 4
    @test findlast(isgreaterequal(2.1), c) === 4
    @test findlast(isgreaterequal(3.1), c) === 4
    @test findlast(isgreaterequal(8.1), c) === nothing

    @test findlast(in(1.1..1.9), c) === nothing
    @test findlast(in(1.1..2.1), c) === 1
    @test findlast(in(1.1..3.1), c) === 2
    @test findlast(in(2.1..3.1), c) === 2

    @test filter(isequal(1.0), c)::MaybeVector == []
    @test filter(isequal(8.0), c)::MaybeVector == [8.0]
    @test filter(isequal(2.0), c)::MaybeVector == [2.0]

    @test issetequal(filter(isless(1.1), c), [])
    @test issetequal(filter(isless(2.0), c), [])
    @test issetequal(filter(isless(2.1), c), [2.0])
    @test issetequal(filter(isless(3.1), c), [2.0, 3.0])
    @test issetequal(filter(isless(8.1), c), [2.0, 3.0, 5.0, 8.0])

    @test issetequal(filter(islessequal(1.1), c), [])
    @test issetequal(filter(islessequal(2.0), c), [2.0])
    @test issetequal(filter(islessequal(2.1), c), [2.0])
    @test issetequal(filter(islessequal(3.1), c), [2.0, 3.0])
    @test issetequal(filter(islessequal(8.1), c), [2.0, 3.0, 5.0, 8.0])

    @test issetequal(filter(isgreater(1.1), c), [2.0, 3.0, 5.0, 8.0])
    @test issetequal(filter(isgreater(2.0), c), [3.0, 5.0, 8.0])
    @test issetequal(filter(isgreater(2.1), c), [3.0, 5.0, 8.0])
    @test issetequal(filter(isgreater(3.1), c), [5.0, 8.0])
    @test issetequal(filter(isgreater(8.1), c), [])

    @test issetequal(filter(isgreaterequal(1.1), c), [2.0, 3.0, 5.0, 8.0])
    @test issetequal(filter(isgreaterequal(2.0), c), [2.0, 3.0, 5.0, 8.0])
    @test issetequal(filter(isgreaterequal(2.1), c), [3.0, 5.0, 8.0])
    @test issetequal(filter(isgreaterequal(3.1), c), [5.0, 8.0])
    @test issetequal(filter(isgreaterequal(8.1), c), [])

    @test issetequal(filter(in(1.1..1.9), c), [])
    @test issetequal(filter(in(1.1..2.1), c), [2.0])
    @test issetequal(filter(in(1.1..3.1), c), [2.0, 3.0])
    @test issetequal(filter(in(2.1..3.1), c), [3.0])

    @test issetequal(innerjoin(identity, identity, tuple, isequal, c, [1.5, 3.0, 8.0]),
                     innerjoin(identity, identity, tuple, isequal, a, [1.5, 3.0, 8.0]))
end