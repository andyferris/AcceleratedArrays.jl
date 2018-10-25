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

Base.summary(i::HashIndex) = "HashIndex ($(length(i.dict)) unique element$(length(i.dict) == 1 ? "" : "s"))"

# Accelerations
Base.in(x, a::AcceleratedArray{<:Any, <:Any, <:Any, <:HashIndex}) = haskey(a.index.dict, x)

function Base.count(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:HashIndex})
    index = Base.ht_keyindex(a.index.dict, f.x)
    if index < 0
        return 0
    else
        return length(a.index.dict.vals[index])
    end
end

function Base.findall(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:HashIndex})
	index = Base.ht_keyindex(a.index.dict, f.x)
	if index < 0
		return Vector{eltype(keys(a))}()
	else
		return @inbounds a.index.dict.vals[index]
	end
end

# TODO: findall for arbitrary predicates by just checking each unique key? (Sometimes faster, sometimes slower?)

function Base.findfirst(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:HashIndex})
	index = Base.ht_keyindex(a.index.dict, f.x)
	if index < 0
		return nothing
	else
		return @inbounds first(a.index.dict.vals[index])
	end
end

function Base.findlast(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:HashIndex})
	index = Base.ht_keyindex(a.index.dict, f.x)
	if index < 0
		return nothing
	else
		return @inbounds last(a.index.dict.vals[index])
	end
end

function Base.filter(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:HashIndex})
	index = Base.ht_keyindex(a.index.dict, f.x)
	if index < 0
		return empty(a)
	else
		return @inbounds parent(a)[a.index.dict.vals[index]]
	end
end

# TODO: filter for arbitrary predicates by just checking each unique key? (Sometimes faster, sometimes slower?)

function Base.unique(a::AcceleratedArray{T, <:Any, <:Any, <:HashIndex}) where {T}
	out = Vector{T}()
	@inbounds for value in keys(a.index.dict)
		push!(out, value)
	end
	return out
end

function SplitApplyCombine.group2(a::AcceleratedArray{<:Any, <:Any, <:Any, <:HashIndex}, b::AbstractArray)
    return Dict((key, @inbounds b[inds]) for (key, inds) in a.index.dict)
end

function SplitApplyCombine.groupreduce(::typeof(identity), f, op, a::AcceleratedArray{<:Any, <:Any, <:Any, <:HashIndex}; kw...)
	return Dict((k, mapreduce(i -> f(@inbounds a[i]), op, v; kw...)) for (k,v) in a.index.dict)
end

function SplitApplyCombine._groupinds(a::AcceleratedArray{<:Any, <:Any, <:Any, <:HashIndex})
	return a.index.dict
end

function SplitApplyCombine._innerjoin!(out, left::AbstractArray, right::AcceleratedArray{<:Any, <:Any, <:Any, <:HashIndex}, v::AbstractArray, ::typeof(isequal))
    @boundscheck if (axes(l)..., axes(r)...) != axes(v)
        throw(DimensionMismatch("innerjoin arrays do not have matching dimensions"))
    end

    dict = right.index.dict

    @inbounds for i ∈ keys(left)
        dict_index = Base.ht_keyindex(dict, left(i_l))
        if dict_index > 0 # -1 if key not found
            for i_r ∈ dict.vals[dict_index]
                push!(out, v[Tuple(i_l)..., Tuple(i_r)...])
            end
        end
    end

    return out
end

function SplitApplyCombine.leftgroupjoin(lkey, ::typeof(identity), f, ::typeof(isequal), left, right::AcceleratedArray{<:Any, <:Any, <:Any, <:HashIndex})
    T = promote_op(f, eltype(left), eltype(right))
    K = promote_op(lkey, eltype(left))

    dict = right.index.dict
    out = Dict{K, Vector{T}}()
    for a ∈ left
        key = lkey(a)
        group = get!(() -> T[], out, key)
        dict_index = Base.ht_keyindex(dict, key)
        if dict_index > 0 # -1 if key not found
            for b ∈ dict.vals[dict_index]
                push!(group, f(a, b))
            end
        end
    end
    return out
end

#=
function SplitApplyCombine.innerjoin(lkey, ::typeof(identity), f, ::typeof(isequal), left, right::AcceleratedArray{<:Any, <:Any, <:Any, <:HashIndex})
    T = promote_op(f, eltype(left), eltype(right))
    dict = right.index.dict
    out = T[]
    for a ∈ left
        key = lkey(a)
        dict_index = Base.ht_keyindex(dict, key)
        if dict_index > 0 # -1 if key not found
            for b ∈ dict.vals[dict_index]
                push!(out, f(a, b))
            end
        end
    end
    return out
end
=#
