@testset "UniqueSortIndex" begin
    a = [3.0, 2.0, 8.0, 5.0]
    b = accelerate(a, UniqueSortIndex)

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

    c = accelerate!(a, UniqueSortIndex) # a = [2.0, 3.0, 5.0, 8.0]

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
end