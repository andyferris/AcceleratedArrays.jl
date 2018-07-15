
struct UniqueSortIndex{O <: AbstractVector} <: AbstractUniqueIndex
	order::O
end

function accelerate(a::AbstractArray, ::Type{UniqueSortIndex})
    order = sortperm(a)
    return AcceleratedArray(a, UniqueSortIndex(order))
end

Base.summary(::UniqueSortIndex) = "UniqueSortIndex"

# Accelerations
function Base.findall(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
	i = searchsortedfirst(view(parent(a), a.index.order), f.x)
	@inbounds if i > length(a.index.order) || !f(parent(a)[a.index.order[i]])
	    return MaybeVector{eltype(a.index.order)}()
	else
		return MaybeVector(a.index.order[i])
	end
end

function Base.filter(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
    i = searchsortedfirst(view(a, a.index.order), f.x)
	@inbounds if i > length(a.index.order) || !f(parent(a)[a.index.order[i]])
	    return MaybeVector{eltype(a)}()
	else
		return MaybeVector(parent(a)[a.index.order[i]])
	end
end
