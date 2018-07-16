# Hash table acceleration index
struct HashIndex{D <: AbstractDict} <: AbstractIndex
    dict::D
end

function HashIndex(a::AbstractArray)
	dict = Dict{eltype(a), Vector{eltype(keys(a))}}()
    
    @inbounds for i in keys(a)
        value = a[i]
        vector = get!(Vector{eltype(keys(a))}, dict, value)
        push!(vector, i)
    end

    return HashIndex(dict)
end

# TODO: accelerate! by put elements in order so we can use ranges as dict values and dict
#       iteration mirrors array iteration for cache friendliness?

Base.summary(dict::HashIndex) = "HashIndex ($(length(dict)) unique  element$(length(dict) == 1 ? "" : "s"))"

# Accelerations
function Base.findall(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:HashIndex})
	index = Base.ht_keyindex(a.index.dict, f.x)
	if index < 0
		return Vector{eltype(keys(a))}()
	else
		return @inbounds a.index.dict.vals[index]
	end
end

# TODO: findall for arbitrary predicates by just checking each unique key?

function Base.filter(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:HashIndex})
	index = Base.ht_keyindex(a.index.dict, f.x)
	if index < 0
		return empty(a)
	else
		return @inbounds parent(a)[a.index.dict.vals[i]]
	end
end

# TODO: filter for arbitrary predicates by just checking each unique key?

function Base.unique(a::AcceleratedArray{T, <:Any, <:Any, <:HashIndex}) where {T}
	out = Vector{T}()
	@inbounds for value in keys(a.index.dict)
		push!(out, value)
	end
	return out
end
