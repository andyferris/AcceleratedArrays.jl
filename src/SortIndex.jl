
struct SortIndex{O <: AbstractVector} <: AbstractIndex
	n_unique::Int
	order::O
end

function accelerate(a::AbstractArray, ::Type{SortIndex})
    order = sortperm(a)
    n_unique = 0
    @inbounds for i in 2:length(order)
    	n_unique += !isequal(a[order[i]], a[order[i-1]])
    end
    return AcceleratedArray(a, SortIndex(n_unique, order))
end

function accelerate!(a::AbstractArray, ::Type{SortIndex})
    sort!(a)
    n_unique = 0
    @inbounds for i in 2:length(a)
    	n_unique += !isequal(a[i], a[i])
    end
    return AcceleratedArray(a, SortIndex(n_unique, keys(a)))
end

Base.summary(s::SortIndex) = "SortIndex ($(s.n_unique) unique element$(s.n_unique == 1 ? "" : "s"))"

# Accelerations
function Base.findall(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    @inbounds a.index.order[searchsorted(view(parent(a), a.index.order), f.x)]
end

function Base.findall(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex{<:LinearIndices}})
    @inbounds searchsorted(parent(a), f.x)
end

function Base.findall(f::Fix2{typeof(isless)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    @inbounds a.index.order[firstindex(a.index.order) : min(lastindex(a.index.order), searchsortedlast(view(parent(a), a.index.order), f.x))]
end

function Base.findall(f::Fix2{typeof(isless)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex{<:LinearIndices}})
    @inbounds firstindex(parent(a)) : min(lastindex(parent(a)), searchsortedlast(parent(a), f.x))
end

function Base.filter(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    @inbounds parent(a)[view(a.index.order, searchsorted(view(parent(a), a.index.order), f.x))]
end

function Base.filter(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex{<:LinearIndices}})
    @inbounds parent(a)[searchsorted(parent(a), f.x)]
end

function Base.filter(f::Fix2{typeof(isless)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    @inbounds parent(a)[a.index.order[firstindex(a.index.order) : min(lastindex(a.index.order), searchsortedlast(view(parent(a), a.index.order), f.x))]]
end

function Base.filter(f::Fix2{typeof(isless)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex{<:LinearIndices}})
    @inbounds parent(a)[firstindex(parent(a)) : min(lastindex(parent(a)), searchsortedlast(parent(a), f.x))]
end