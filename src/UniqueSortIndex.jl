
struct UniqueSortIndex{O <: AbstractVector} <: AbstractUniqueIndex
	order::O
end

function accelerate(a::AbstractArray, ::Type{UniqueSortIndex})
    order = sortperm(a)
    return AcceleratedArray(a, UniqueSortIndex(order))
end

function accelerate!(a::AbstractArray, ::Type{UniqueSortIndex})
    sort!(a)
    return AcceleratedArray(a, UniqueSortIndex(keys(a)))
end

Base.summary(::UniqueSortIndex) = "UniqueSortIndex"

# Accelerations
function Base.findall(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
	i = searchsortedfirst(view(parent(a), a.index.order), f.x)
	@inbounds if i > lastindex(a.index.order) || !f(parent(a)[a.index.order[i]])
	    return MaybeVector{eltype(a.index.order)}()
	else
		return MaybeVector(a.index.order[i])
	end
end

function Base.findall(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
	i = searchsortedfirst(parent(a), f.x)
	@inbounds if i > lastindex(parent(a)) || !f(parent(a)[i])
	    return MaybeVector{typeof(i)}()
	else
		return MaybeVector(i)
	end
end

function Base.findall(f::Fix2{typeof(isless)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
    @inbounds a.index.order[firstindex(a.index.order) : min(lastindex(a.index.order), searchsortedlast(view(parent(a), a.index.order), f.x))]
end

function Base.findall(f::Fix2{typeof(isless)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    @inbounds firstindex(parent(a)) : min(lastindex(parent(a)), searchsortedlast(parent(a), f.x))
end

function Base.filter(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
    i = searchsortedfirst(view(parent(a), a.index.order), f.x)
	if i > lastindex(a.index.order)
		return MaybeVector{eltype(a)}()
	end
	x = @inbounds a[a.index.order[i]]
	return f(x) ? MaybeVector(x) : MaybeVector{eltype(a)}()
end

function Base.filter(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
	i = searchsortedfirst(parent(a), f.x)
	if i > lastindex(parent(a))
		return MaybeVector{eltype(a)}()
	end
	x = @inbounds a[i]
	return f(x) ? MaybeVector(x) : MaybeVector{eltype(a)}()
end

function Base.filter(f::Fix2{typeof(isless)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
    @inbounds parent(a)[a.index.order[firstindex(a.index.order) : min(lastindex(a.index.order), searchsortedlast(view(parent(a), a.index.order), f.x))]]
end

function Base.filter(f::Fix2{typeof(isless)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    @inbounds parent(a)[firstindex(parent(a)) : min(lastindex(parent(a)), searchsortedlast(parent(a), f.x))]
end
