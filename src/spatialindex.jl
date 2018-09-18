export BoxTree, BoxNode, Box, make_boxnode!, make_boxtree!, split_largest_dim
export RTree, RNode, construct_rtree!, construct_rnodes!
"""
    Box(v1, v2)

Return an axis-aligned box.
"""
struct Box{V <: AbstractVector}
    mins::V
    maxs::V
end

function Box(v1::V, v2::V) where {V <: AbstractVector}
    return Box{V}(min.(v1, v2), max.(v1, v2))
end

function Box(box::Box{V}, v::V) where {V}
    return Box{V}(min.(box.mins, v), max.(box.maxs, v))
end

function Box(v::V, box::Box{V}) where {V}
    return Box{V}(min.(box.mins, v), max.(box.maxs, v))
end

function Box(box1::Box{V}, box2::Box{V}) where {V}
    return Box{V}(min.(box1.mins, box2.mins), max.(box1.maxs, box2.maxs))
end

function Box(vs::AbstractVector{V}) where {V <: AbstractVector}
    mins = reduce((v1, v2) -> min.(v1, v2), vs)
    maxs = reduce((v1, v2) -> max.(v1, v2), vs)

    return Box{V}(mins, maxs)
end

function intersects(box1::Box, box2::Box)
    @inbounds ! ( box1.maxs[1] < box2.mins[1] || box1.mins[1] > box2.maxs[1] ||
        box1.maxs[2] < box2.mins[2] || box1.mins[2] > box2.maxs[2] ||
        box1.maxs[3] < box2.mins[3] || box1.mins[3] > box2.maxs[3] )
end


#function intersects(box1::Box, box2::Box)
#   box1.mins in box2 || box1.maxs in box2 || box2.mins in box1 || box2.maxs in box1
#end

Base.eltype(::Type{Box{V}}) where {V} = V
Base.eltype(b::Box) = eltype(typeof(b))

Base.show(io::IO, box::Box) = print(io, "Box($(box.mins), $(box.maxs))")

function Base.in(v::AbstractVector, box::Box)
    mapreduce(>=, &, v, box.mins) & mapreduce(<=, &, v, box.maxs)
end

volume(box::Box) = prod(box.maxs - box.mins)

function split_largest_dim(box::Box)
    (difference, dim) = findmax(box.maxs - box.mins)
    @inbounds split = box.mins[dim] + difference / 2

    box1 = Box(box.mins, setindex(box.maxs, split, dim))
    box2 = Box(setindex(box.mins, split, dim), box.maxs)
    
    return (box1, box2)
end   

struct BoxNode{V <: AbstractVector}
    box::Box{V}
    inds::UnitRange{Int}
    children::Vector{BoxNode{V}}

    function BoxNode{V}(box::Box{V}, inds::UnitRange{Int}) where {V}
        new(box, inds)
    end

    function BoxNode{V}(box::Box{V}, inds::UnitRange{Int}, children::Vector{BoxNode{V}}) where {V}
        new(box, inds, children)
    end
end

const n_leaf_elements = 10

function make_boxnode_half!(vs::AbstractVector{<:AbstractVector}, box::Box, indmin::Int, indmax::Int)
    if indmax - indmin <= n_leaf_elements
        return BoxNode{eltype(vs)}(box, indmin:indmax)
    end

    (box1, box2) = split_largest_dim(box::Box)
    sort!(view(vs, indmin:indmax); by = in(box2))
    indmin2 = searchsortedfirst(in(box2).(view(vs, indmin:indmax)), true) + indmin - 1
    indmax1 = indmin2 - 1

    child1 = make_boxnode_half!(vs, box1, indmin, indmax1)
    child2 = make_boxnode_half!(vs, box2, indmin2, indmax)

    return BoxNode{eltype(vs)}(box, indmin:indmax, [child1, child2])
end

function make_boxnode_median!(vs::AbstractVector{<:AbstractVector}, box::Box, indmin::Int, indmax::Int)
    if indmax - indmin <= n_leaf_elements
        return BoxNode{eltype(vs)}(box, indmin:indmax)
    end

    (difference, dim) = findmax(box.maxs - box.mins)
    @inbounds sort!(view(vs, indmin:indmax); by = v -> @inbounds v[dim])

    indmin2 = (indmin + indmax) >>> 1
    indmax1 = indmin2 - 1

    split = (vs[indmin2][dim] + vs[indmax1][dim]) / 2

    box1 = Box(box.mins, setindex(box.maxs, split, dim))
    box2 = Box(setindex(box.mins, split, dim), box.maxs)

    child1 = make_boxnode_median!(vs, box1, indmin, indmax1)
    child2 = make_boxnode_median!(vs, box2, indmin2, indmax)

    return BoxNode{eltype(vs)}(box, indmin:indmax, [child1, child2])
end

function make_boxnode_median_and_shrink!(vs::AbstractVector{<:AbstractVector}, box::Box, indmin::Int, indmax::Int)
    if indmax - indmin <= n_leaf_elements
        return BoxNode{eltype(vs)}(box, indmin:indmax)
    end

    (difference, dim) = findmax(box.maxs - box.mins)
    @inbounds sort!(view(vs, indmin:indmax); by = v -> @inbounds v[dim])

    indmin2 = (indmin + indmax) >>> 1
    indmax1 = indmin2 - 1

    mins1 = reduce((v1, v2) -> min.(v1, v2), view(vs, indmin:indmax1))
    maxs1 = reduce((v1, v2) -> max.(v1, v2), view(vs, indmin:indmax1))
    box1 = Box(mins1, maxs1)

    mins2 = reduce((v1, v2) -> min.(v1, v2), view(vs, indmin2:indmax))
    maxs2 = reduce((v1, v2) -> max.(v1, v2), view(vs, indmin2:indmax))
    box2 = Box(mins2, maxs2)

    child1 = make_boxnode_median_and_shrink!(vs, box1, indmin, indmax1)
    child2 = make_boxnode_median_and_shrink!(vs, box2, indmin2, indmax)

    return BoxNode{eltype(vs)}(box, indmin:indmax, [child1, child2])
end

function make_boxnode_half_and_shrink!(vs::AbstractVector{<:AbstractVector}, box::Box, indmin::Int, indmax::Int)
    if indmax - indmin <= n_leaf_elements
        return BoxNode{eltype(vs)}(box, indmin:indmax)
    end

    (box1, box2) = split_largest_dim(box::Box)
    sort!(view(vs, indmin:indmax); by = in(box2))
    indmin2 = searchsortedfirst(in(box2).(view(vs, indmin:indmax)), true) + indmin - 1
    indmax1 = indmin2 - 1

    mins1 = reduce((v1, v2) -> min.(v1, v2), view(vs, indmin:indmax1))
    maxs1 = reduce((v1, v2) -> max.(v1, v2), view(vs, indmin:indmax1))
    box1_shrunk = Box(mins1, maxs1)

    mins2 = reduce((v1, v2) -> min.(v1, v2), view(vs, indmin2:indmax))
    maxs2 = reduce((v1, v2) -> max.(v1, v2), view(vs, indmin2:indmax))
    box2_shrunk = Box(mins2, maxs2)

    child1 = make_boxnode_half_and_shrink!(vs, box1_shrunk, indmin, indmax1)
    child2 = make_boxnode_half_and_shrink!(vs, box2_shrunk, indmin2, indmax)

    return BoxNode{eltype(vs)}(box, indmin:indmax, [child1, child2])
end


function make_boxnode_optimize_split!(vs::AbstractVector{<:AbstractVector}, box::Box, indmin::Int, indmax::Int)
    if indmax - indmin <= n_leaf_elements
        return BoxNode{eltype(vs)}(box, indmin:indmax)
    end

    (difference, dim) = findmax(box.maxs - box.mins)
    @inbounds sort!(view(vs, indmin:indmax); by = v -> @inbounds v[dim])

    volumes = zeros(indmax - indmin + 1)
    box_left = Box(vs[indmin], vs[indmin])
    for i in 2 : indmax - indmin + 1
        box_left = Box(box_left, vs[indmin + i - 1])
        volumes[i] = volume(box_left)
    end

    box_right = Box(vs[indmax], vs[indmax])
    for i in indmax - indmin : -1 : 1
        box_right = Box(box_right, vs[indmin + i - 1])
        volumes[i] += volume(box_right)
    end

    (min_volume, i_min_volume) = findmin(volumes)

    indmin2 = indmin + i_min_volume
    indmax1 = indmin2 - 1

    mins1 = reduce((v1, v2) -> min.(v1, v2), view(vs, indmin:indmax1))
    maxs1 = reduce((v1, v2) -> max.(v1, v2), view(vs, indmin:indmax1))
    box1_shrunk = Box(mins1, maxs1)

    mins2 = reduce((v1, v2) -> min.(v1, v2), view(vs, indmin2:indmax))
    maxs2 = reduce((v1, v2) -> max.(v1, v2), view(vs, indmin2:indmax))
    box2_shrunk = Box(mins2, maxs2)

    child1 = make_boxnode_optimize_split!(vs, box1_shrunk, indmin, indmax1)
    child2 = make_boxnode_optimize_split!(vs, box2_shrunk, indmin2, indmax)

    return BoxNode{eltype(vs)}(box, indmin:indmax, [child1, child2])
end



struct BoxTree{V <: AbstractVector}
    rootnode::BoxNode{V}
end

function make_boxtree!(vs::AbstractVector{<:AbstractVector}; algorithm::Symbol = :optimize_split)
    indmin = firstindex(vs)
    indmax = lastindex(vs)
    mins = reduce((v1, v2) -> min.(v1, v2), vs)
    maxs = reduce((v1, v2) -> max.(v1, v2), vs)
    box = Box(mins, maxs)
 
    if algorithm == :half
        rootnode = make_boxnode_half!(vs, box, indmin, indmax)
    elseif algorithm == :half_and_shrink
        rootnode = make_boxnode_half_and_shrink!(vs, box, indmin, indmax)
    elseif algorithm == :median
        rootnode = make_boxnode_median!(vs, box, indmin, indmax)
    elseif algorithm == :median_and_shrink
        rootnode = make_boxnode_median_and_shrink!(vs, box, indmin, indmax)
    elseif algorithm == :optimize_split
        rootnode = make_boxnode_optimize_split!(vs, box, indmin, indmax)
    else
        error("Unknown algorithm  = :$algorithm")
    end
    return BoxTree{eltype(vs)}(rootnode)
end

Base.show(io::IO, bt::BoxTree) = print(io, "BoxTree of $(length(bt.rootnode.inds)) points in $(bt.rootnode.box)")

@inline yes(x) = true

function findindices(vs::AbstractVector, bt::BoxTree, searchbox::Box)
    findindices(vs, bt, searchbox, yes)
end

function findindices(vs::AbstractVector, bt::BoxTree, geometry)
    findindices(vs, bt, Box(geometry), in(geometry))
end

function findindices(vs::AbstractVector, bt::BoxTree, searchbox::Box, f)
    out = Vector{Int}()
    findindices!(out, vs, bt.rootnode, searchbox, f)

    return out
end

function findindices!(inds::Vector{Int}, vs::AbstractVector, bn::BoxNode, searchbox::Box, f)
    if isdefined(bn, :children)
        for child in bn.children
            if intersects(child.box, searchbox)
                 findindices!(inds, vs, child, searchbox, f)
            end
        end
        
        return nothing
    end

    @inbounds for i in bn.inds
        v = vs[i]
        if v in searchbox && f(v)
            push!(inds, i)
        end
    end

    return nothing
end


struct RNode{V <: AbstractVector}
    box::Box{V}
    inds::UnitRange{Int}
    child1::Int
    child2::Int
end

struct RTree{V <: AbstractVector}
    nodes::Vector{RNode{V}}
end

function construct_rtree!(points::AbstractVector{V}) where {V <: AbstractVector}
    indmin = firstindex(points)
    indmax = lastindex(points)

    nodes = Vector{RNode{V}}()

    construct_rnodes!(nodes, points, indmin, indmax)

    return RTree{V}(nodes)
end

function construct_rnodes!(nodes::Vector{RNode{V}}, points::AbstractVector{V}, imin::Int, imax::Int) where {V}
    mins = reduce((v1, v2) -> min.(v1, v2), view(points, imin:imax))
    maxs = reduce((v1, v2) -> max.(v1, v2), view(points, imin:imax))
    box = Box(mins, maxs)

    push!(nodes, RNode(box, imin:imax, 0, 0))
    if imax - imin + 1 <= n_leaf_elements
        return 1
    end
    
    thisnode = lastindex(nodes)
    (box1, box2) = split_largest_dim(box::Box)
    sort!(view(points, imin:imax); by = in(box2))

    imin2 = searchsortedfirst(in(box2).(view(points, imin:imax)), true) + imin - 1
    imax1 = imin2 - 1

    @assert imax1 < imax
    @assert imin2 > imin

    n_children_1 = construct_rnodes!(nodes, points, imin, imax1)
    n_children_2 = construct_rnodes!(nodes, points, imin2, imax)
    
    child1 = thisnode + 1
    child2 = child1 + n_children_1
    nodes[thisnode] = RNode(box, imin:imax, child1, child2)

    return 1 + n_children_1 + n_children_2
end

function findindices(vs::AbstractVector, tree::RTree, searchbox::Box)
    findindices(vs, tree, searchbox, yes)
end

function findindices(vs::AbstractVector, tree::RTree, geometry)
    findindices(vs, tree, Box(geometry), in(geometry))
end

function findindices(vs::AbstractVector, tree::RTree, searchbox::Box, f)
    out = Vector{Int}()

    findindices!(out, vs, tree.nodes, 1, searchbox, f)

    return out
end

function findindices!(inds::Vector{Int}, vs::AbstractVector, nodes::Vector{<:RNode}, inode, searchbox::Box, f)
    @inbounds node = nodes[inode]
    @inbounds if node.child1 == 0
        for i in node.inds
            v = vs[i]
            if v in searchbox && f(v)
                push!(inds, i)
            end
        end
    else
        childnode1 = nodes[node.child1]
        if intersects(childnode1.box, searchbox)
            findindices!(inds, vs, nodes, node.child1, searchbox, f)
        end

        childnode2 = nodes[node.child2]
        if intersects(childnode2.box, searchbox)
            findindices!(inds, vs, nodes, node.child2, searchbox, f)
        end
    end
    return nothing
end

function findindices2(vs::AbstractVector, tree::RTree, searchbox::Box)
    findindices2(vs, tree, searchbox, yes)
end

function findindices2(vs::AbstractVector, tree::RTree, geometry)
    findindices2(vs, tree, Box(geometry), in(geometry))
end

function findindices2(vs::AbstractVector, tree::RTree, searchbox::Box, f)
    out = Vector{Int}()

    findindices2!(out, vs, tree.nodes, searchbox, f)

    return out
end

function findindices2!(inds::Vector{Int}, vs::AbstractVector, nodes::Vector{<:RNode}, searchbox::Box, f)
    stack = fill(0, 32)
    @inbounds stack[1] = 1
    istack = 1

    @inbounds while istack > 0
        inode = stack[istack]
        node = nodes[inode]
        if node.child1 == 0
            for i in node.inds
                v = vs[i]
                if v in searchbox && f(v)
                    push!(inds, i)
                end
            end
            istack -= 1
        else
            childnode1 = nodes[node.child1]
            childnode2 = nodes[node.child2]

            if intersects(childnode2.box, searchbox)
                stack[istack] = node.child2

                if intersects(childnode1.box, searchbox)
                    istack += 1
                    stack[istack] = node.child1
                end
            else
                if intersects(childnode1.box, searchbox)
                    stack[istack] = node.child1
                else
                    istack -= 1
                end
            end
        end
    end
    return nothing
end


#=
struct BoxNode{V <: AbstractVector}
    mins::V
    maxs::V
    indexmin::Int
    indexmax::Int
    child1::Int
    child2::Int
end

BoxNode(box::Box{V}, indexmin::Int, indexmax::Int) where {V} = BoxNode{V}(box.mins, box.maxs, indexmin, indexmax, 0, 0)

function addchildren(parent::BoxNode{V}, child1::Int, child2::Int) where {V}
    BoxNode{V}(parent.mins, parent.maxs, parent.indexmin, parent.indexmax, child1, child2)
end

struct BoxTree{V <: AbstractVector, O <: AbstractVector{Int}}
    nodes::Vector{BoxNode{V}}
    order::O
end

function BoxTree(vs::AbstractVector{V}) where {V <: AbstractVector}
    mins = min.(vs)
    maxs = max.(vs)
    indexmin = firstindex(vs)::Int
    indexmax = lastindex(vs)::Int

    nodes = Vector{BoxNode{V}}()
    push!(nodes, BoxNode(maxs, mins, indexmin, indexmax))

    indices = Vector(indexmin:indexmax)
    create_tree!(nodes, 1, vs, indexmin, indexmax)

    return BoxTree{V}(nodes)
end

const max_leaf_elements = 10
const min_node_size = 0.5

function create_tree!(nodes::Vector{<:BoxNode}, i::Int, vs::AbstractVector{<:AbstractVector}, indexmin::Int, indexmax::Int)
    thisnode = @inbounds nodes[i]
    (dim, split, box1, box2) = split_largest_dim(Box(thisnode.mins, thisnode.maxs))


end


function split_largest_dim(box::Box)
    dim = findmax(box.max - box.min)
    @inbounds split = (box.min[dim] + box.max[dim]) / 2

    box1 = Box(box.min, setindex(box.max, split, dim))
    box2 = Box(setindex(box.min, split, dim), box.max)

    return (dim, split, box1, box2)
end
=#