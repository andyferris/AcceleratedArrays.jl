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

    @test 0 ∈ 0 .. 0
    @test 0 ∉ 0 .. -1

    @test interval == interval
    @test interval != -1..1
    @test interval != 0..2
    @test interval != 0..0
    @test interval != 1..1
    @test interval == 0.0 .. 1.0
    @test 0 .. 0 == 0 .. 0
    @test 0 .. 0 != 1 .. 0
    @test 0 .. -1 == 1 .. 0

    @test isequal(interval, interval)
    @test !isequal(interval, -1..1)
    @test !isequal(interval, 0..2)
    @test !isequal(interval, 0..0)
    @test !isequal(interval, 1..1)
    @test isequal(interval, 0.0 .. 1.0)
    @test isequal(0 .. 0, 0 .. 0)
    @test !isequal(0 .. 0, 1 .. 0)
    @test isequal(0 .. -1, 1 .. 0)

    @test isless(0..1, 2..3)
    @test !isless(2..3, 0..1)
    @test isless(0..1, 0..2)
    @test !isless(0..2, 0..1)

    @test !isless(0..0, 0..0)
    @test isless(0..0, 1..1)
    @test isless(0..0, 1..0)
    @test isless(0..0, 1 .. -1)
    @test isless(0..0, 0..1)
    @test isless(0..0, 0 .. -1)
    @test !isless(1..1, 0..0)
    @test !isless(1..0, 0..0)
    @test !isless(1 .. -1, 0..0)
    @test !isless(0..1, 0..0)
    @test !(isless(0 .. -1, 0..0))
end

@testset "lessthan and greaterthan" begin
    interval = greaterthan(0) .. lessthan(1)

    @test -1 ∉ interval
    @test 0 ∉ interval
    @test 0.5 ∈ interval
    @test 1 ∉ interval
    @test 2 ∉ interval
end