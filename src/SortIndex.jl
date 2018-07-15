
struct SortIndex{O <: AbstractVector} <: AbstractIndex
	order::O
end

function accelerate(a::AbstractArray, ::Type{SortIndex})
    order = sortperm(a)
    return AcceleratedArray(a, SortIndex(order))
end

Base.summary(::SortIndex) = "SortIndex"

# Accelerations
function Base.findall(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    @inbounds a.index.order[searchsorted(view(parent(a), a.index.order), f.x)]
end

function Base.filter(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    @inbounds parent(a)[view(a.index.order, searchsorted(view(parent(a), a.index.order), f.x))]
end
