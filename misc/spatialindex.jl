# A test script for the spatial index

using AcceleratedArrays
using StaticArrays
using RoamesGeometry
using Colors
using Displaz
using DelimitedFiles
using Random
using BenchmarkTools

struct Sphere{T, V <: AbstractVector{T}}
	centre::V
	radius::T
end

Sphere(centre::AbstractVector{T}, r::T) where {T} = Sphere{T, typeof(centre)}(centre, r)

function Base.in(p::AbstractVector{T}, sphere::Sphere{T}) where {T}
    sum(abs2, p - sphere.centre) <= sphere.radius^2
end

AcceleratedArrays.Box(sphere::Sphere) = Box(map(x -> x - sphere.radius, sphere.centre),
	                                        map(x -> x + sphere.radius, sphere.centre))


Base.rand(rng::AbstractRNG, box::Box) = map((min, max) -> min + (max - min) * rand(rng), box.mins, box.maxs)
Random.rand!(rng::AbstractRNG, a::AbstractArray, box::Box) = map!(x -> rand(rng, box), a, a)

function Displaz.plot3d(bt::BoxTree; kwargs...)
	lines = wireframe(bt.rootnode)
	plot3d(lines; kwargs...)
end

function Displaz.plot3d!(bt::BoxTree; kwargs...)
	lines = wireframe(bt.rootnode)
	plot3d!(lines; kwargs...)
end

function RoamesGeometry.wireframe(bn::BoxNode)
	wires = wireframe(bn.box)
    if isdefined(bn, :children)
		for child in bn.children
			append!(wires, wireframe(child))
		end
	end
	return wires
end

function RoamesGeometry.wireframe(box::Box)
	return wireframe(BoundingBox(box.mins..., box.maxs...))
end

function Displaz.plot3d(bn::BoxNode, i; kwargs...)
	plot3d(bn.box; color = colors[i], label = "BoxTree (level $i)", kwargs...)
	if isdefined(bn, :children)
		for child in bn.children
			plot3d(child, i+1; kwargs...)
		end
	end
end

function Displaz.plot3d(box::Box; kwargs...)
	plot3d(wireframe(BoundingBox(box.mins..., box.maxs...)); kwargs...)
end

RoamesGeometry.volume(box::Box) = prod(box.maxs - box.mins)

fill_volume(bt::BoxTree) = fill_volume(bt.rootnode)
function fill_volume(bn::BoxNode)
	if isdefined(bn, :children)
		return sum(fill_volume, bn.children)
	else
		return volume(bn.box)
	end
end

total_volume(bt::BoxTree) = total_volume(bt.rootnode)
function total_volume(bn::BoxNode)
	if isdefined(bn, :children)
		return volume(bn.box) + sum(total_volume, bn.children)
	else
		return volume(bn.box)
	end
end


function average_num_neighbors(points, boxtree::Union{RTree,BoxTree}, searchpoints, radius)
	total_neighbors = 0
	@inbounds for p in searchpoints
	    searchsphere = Sphere(p, radius)
	    #searchbox = Box(map(x -> x - boxsize, p), map(x -> x + boxsize, p))
        inds = AcceleratedArrays.findindices(points, boxtree, searchsphere)
        total_neighbors += length(inds)
	end
	return total_neighbors / length(searchpoints)
end

function average_num_neighbors2(points, rtree::RTree, searchpoints, radius)
	total_neighbors = 0
	@inbounds for p in searchpoints
	    searchsphere = Sphere(p, radius)
	    #searchbox = Box(map(x -> x - boxsize, p), map(x -> x + boxsize, p))
        inds = AcceleratedArrays.findindices2(points, rtree, searchsphere)
        total_neighbors += length(inds)
	end
	return total_neighbors / length(searchpoints)
end


colors = [RGB(1.0, 0.0, 0.0), RGB(1.0, 1.0, 0.0), RGB(0.0,1.0,0.0), RGB(0.0, 1.0, 1.0), RGB(0.0, 0.0, 1.0), RGB(1.0, 0.0, 1.0)]
colors = [colors; colors; colors; colors; colors; colors]
#algs = [:half, :half_and_shrink, :median, :median_and_shrink, :optimize_split]
algs = [:half_and_shrink]

#=
#points = [SVector(rand(), rand(), rand()) for i in 1:1000]
points = rand(Box(SVector(0.0, 0.0, 0.0), SVector(1.0, 1.0, 1.0)), 1000)
searchpoints = rand(Box(SVector(0.0, 0.0, 0.0), SVector(1.0, 1.0, 1.0)), 1000)

println("Randomly distributed points")
println("---------------------------")
for alg in algs
    println("Algorihm :$alg") 
	boxtree = make_boxtree!(points; algorithm = alg)
    @time make_boxtree!(points; algorithm = alg)

	plot3d(points; label = "Random distrubution points, $alg")
	plot3d(boxtree; label = "Random distrubution tree, $alg")

	println("Leaf percentage of level 1 volume is $(Float32(100*fill_volume(boxtree)/volume(boxtree.rootnode.box)))%")
	println("Total percentage of level 1 volume is $(Float32(100*total_volume(boxtree)/volume(boxtree.rootnode.box)))%")
	avg_neighbors = average_num_neighbors(points, boxtree, points, 0.1)
	println("Average number of neighbors of points is $avg_neighbors") 
	@btime average_num_neighbors($points, $boxtree, $points, $0.1)
    avg_neighbors2 = average_num_neighbors(points, boxtree, searchpoints, 0.1)
	println("Average number of neighbors of $(length(searchpoints)) randomly distributed points is $avg_neighbors2") 
	@btime average_num_neighbors($points, $boxtree, $searchpoints, $0.1)
    println()
end
=#

println("Norman Park extract")
println("-------------------")

mat = readdlm("/home/ferris/.julia/dev/AcceleratedArrays/misc/normanpark.dlm")
points = [SVector(mat[i, 1], mat[i, 2], mat[i, 3]) for i in 1:size(mat, 1)]
searchpoints = rand(Box(points), 1000)

plot3d!(points; label = "Norman Park points")

println("Algorithm :RTree (manual stack)") 
rtree = construct_rtree!(points)
@time construct_rtree!(points)

#println("Leaf percentage of level 1 volume is $(Float32(100*fill_volume(boxtree)/volume(boxtree.rootnode.box)))%")
#println("Total percentage of level 1 volume is $(Float32(100*total_volume(boxtree)/volume(boxtree.rootnode.box)))%")
for radius in [0.25, 0.5, 1.0, 2.0]
    avg_neighbors = average_num_neighbors2(points, rtree, points, radius)
	println("Average number of neighbors within radius $radius of points is $avg_neighbors") 
	@btime average_num_neighbors2($points, $rtree, $points, $radius)
    avg_neighbors2 = average_num_neighbors2(points, rtree, searchpoints, radius)
	println("Average number of neighbors with radius $radius of $(length(searchpoints)) randomly distributed points is $avg_neighbors2") 
	@btime average_num_neighbors2($points, $rtree, $searchpoints, $radius)
end
println()

println("Algorithm :RTree (recursive)") 
rtree = construct_rtree!(points)
@time construct_rtree!(points)

#println("Leaf percentage of level 1 volume is $(Float32(100*fill_volume(boxtree)/volume(boxtree.rootnode.box)))%")
#println("Total percentage of level 1 volume is $(Float32(100*total_volume(boxtree)/volume(boxtree.rootnode.box)))%")
for radius in [0.25, 0.5, 1.0, 2.0]
    avg_neighbors = average_num_neighbors(points, rtree, points, radius)
	println("Average number of neighbors within radius $radius of points is $avg_neighbors") 
	@btime average_num_neighbors($points, $rtree, $points, $radius)
    avg_neighbors2 = average_num_neighbors(points, rtree, searchpoints, radius)
	println("Average number of neighbors with radius $radius of $(length(searchpoints)) randomly distributed points is $avg_neighbors2") 
	@btime average_num_neighbors($points, $rtree, $searchpoints, $radius)
end
println()


for alg in algs
    println("Algorithm :$alg") 
	boxtree = make_boxtree!(points; algorithm = alg)
	@time make_boxtree!(points; algorithm = alg)

	plot3d!(boxtree; label = "Norman Park BoxTree, $alg")

	println("Leaf percentage of level 1 volume is $(Float32(100*fill_volume(boxtree)/volume(boxtree.rootnode.box)))%")
	println("Total percentage of level 1 volume is $(Float32(100*total_volume(boxtree)/volume(boxtree.rootnode.box)))%")
	for radius in [0.25, 0.5, 1.0, 2.0]
	    avg_neighbors = average_num_neighbors(points, boxtree, points, radius)
		println("Average number of neighbors within radius $radius of points is $avg_neighbors") 
		@btime average_num_neighbors($points, $boxtree, $points, $radius)
	    avg_neighbors2 = average_num_neighbors(points, boxtree, searchpoints, radius)
		println("Average number of neighbors with radius $radius of $(length(searchpoints)) randomly distributed points is $avg_neighbors2") 
		@btime average_num_neighbors($points, $boxtree, $searchpoints, $radius)
	end
    println()
end

using NearestNeighbors

function average_num_neighbors(points, tree::KDTree, searchpoints, radius)
	total_neighbors = 0
    @inbounds for p in searchpoints
	    result = inrange(tree, p, radius)
        total_neighbors += length(result)
	end
	return total_neighbors / length(searchpoints)
end

println("Algorithm: KDTree (NearestNeighbors.jl)")
kdtree = KDTree(points)
@time KDTree(points)
for radius in [0.25, 0.5, 1.0, 2.0]
    avg_neighbors = average_num_neighbors(points, kdtree, points, radius)
	println("Average number of neighbors within radius $radius of points is $avg_neighbors") 
	@btime average_num_neighbors($points, $kdtree, $points, $radius)
    avg_neighbors2 = average_num_neighbors(points, kdtree, searchpoints, radius)
	println("Average number of neighbors with radius $radius of $(length(searchpoints)) randomly distributed points is $avg_neighbors2") 
	@btime average_num_neighbors($points, $kdtree, $searchpoints, $radius)
end

