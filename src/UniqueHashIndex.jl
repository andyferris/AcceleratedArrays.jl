# Hash table acceleration index
struct UniqueHashIndex{D <: Dict} <: AbstractUniqueIndex
    dict::D
end 

function UniqueHashIndex(a::AbstractArray)
	dict = Dict{eltype(a), SingleVector{eltype(keys(a))}}()

    @inbounds for i in keys(a)
        value = a[i]
        index = Base.ht_keyindex2!(dict, value)
	    if index > 0 # `value` found in `dict`
	        error("Input not unique") # TODO Use appropriate Exception
	    else # `value` is ready to be inserted into `dict` at slot `-index`
	        @inbounds Base._setindex!(dict, SingleVector(i), value, -index)
	    end
    end
    return UniqueHashIndex(dict)
end

Base.summary(::UniqueHashIndex) = "UniqueHashIndex"

# Accelerations
Base.in(x, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueHashIndex}) = haskey(a.index.dict, x)

function Base.count(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueHashIndex})
    index = Base.ht_keyindex(a.index.dict, f.x)
    if index < 0
        return 0
    else
        return 1
    end
end

function Base.findall(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueHashIndex})
	index = Base.ht_keyindex(a.index.dict, f.x)
	if index < 0
		return MaybeVector{eltype(keys(a))}()
	else
		return MaybeVector(@inbounds a.index.dict.vals[index][])
	end
end

function Base.filter(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueHashIndex})
	index = Base.ht_keyindex(a.index.dict, f.x)
	if index < 0
		return MaybeVector{eltype(a)}()
	else
		return MaybeVector{eltype(a)}(f.x)
	end
end

function SplitApplyCombine.group2(a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueHashIndex}, b::AbstractArray)
    return Dict((key, SingleVector(@inbounds b[inds[]])) for (key, inds) in a.index.dict)
end

function SplitApplyCombine.groupreduce(::typeof(identity), f, op, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueHashIndex}; kw...)
	return Dict((k, mapreduce(i -> f(@inbounds a[i]), op, v; kw...)) for (k, v) in a.index.dict)
end

function SplitApplyCombine._groupinds(a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueHashIndex})
	return a.index.dict
end

function SplitApplyCombine._innerjoin!(out, left::AbstractArray, right::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueHashIndex}, v::AbstractArray, ::typeof(isequal))
    @boundscheck if (axes(l)..., axes(r)...) != axes(v)
        throw(DimensionMismatch("innerjoin arrays do not have matching dimensions"))
    end

    dict = right.index.dict

    @inbounds for i ∈ keys(left)
        dict_indUniqueex = Base.ht_keyindex(dict, left(i_l))
        if dict_index > 0 # -1 if key not found
            i_r = dict.vals[dict_index][]
            push!(out, v[Tuple(i_l)..., Tuple(i_r)...])
        end
    end

    return out
end
