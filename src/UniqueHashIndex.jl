# Hash table acceleration index
mutable struct UniqueHashIndex{D <: HashDictionary,A <: AbstractArray} <: AbstractUniqueIndex
    dict::D
    arr::A
    initialised::Bool
end 

function UniqueHashIndex(a::AbstractArray)
    dict = HashDictionary{eltype(a),SingleVector{eltype(keys(a))}}()
    return UniqueHashIndex(dict, a, false)
end

function initialised(index::UniqueHashIndex)
    if !index.initialised
        @inbounds for i in keys(index.arr)
            value = index.arr[i]
            (hadindex, token) = gettoken!(index.dict, value)
            if hadindex
                error("Input not unique") # TODO Use appropriate Exception
            else # `value` is ready to be inserted into `dict` at slot `-index`
                @inbounds settokenvalue!(index.dict, token, SingleVector(i))
            end
        end
        index.initialised = true
    end
    return index
end

getdict(index::UniqueHashIndex) = initialised(index).dict

# Not lazy by default
accelerate(a::AbstractArray, ::Type{UniqueHashIndex}) = accelerate(a, UniqueHashIndex, false)

function accelerate(a::AbstractArray, ::Type{UniqueHashIndex}, lazy::Bool)
    aa = AcceleratedArray(a, UniqueHashIndex(a))
    if !lazy
        initialised(aa.index)
    end
    return aa
end

Base.summary(::UniqueHashIndex) = "UniqueHashIndex"

# Accelerations
Base.in(x, a::AcceleratedArray{<:Any,<:Any,<:Any,<:UniqueHashIndex}) = haskey(getdict(a.index), x)

function Base.count(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any,<:Any,<:Any,<:UniqueHashIndex})
    if f.x in keys(getdict(a.index))
        return 1
    else
        return 0
    end
end

function Base.findall(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any,<:Any,<:Any,<:UniqueHashIndex})
    dict = getdict(a.index)
    (hasindex, token) = gettoken(dict, f.x)
    if hasindex
        return MaybeVector(@inbounds gettokenvalue(dict, token)[])
    else
        return MaybeVector{eltype(keys(a))}()
    end
end

function Base.filter(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any,<:Any,<:Any,<:UniqueHashIndex})
    if f.x in keys(getdict(a.index))
        return MaybeVector{eltype(a)}(f.x)
    else
        return MaybeVector{eltype(a)}()
    end
end

function SplitApplyCombine.group(a::AcceleratedArray{<:Any,<:Any,<:Any,<:UniqueHashIndex}, b::AbstractArray)
    return map(inds->SingleVector(@inbounds b[inds[]]), getdict(a.index))
end

function SplitApplyCombine.groupreduce(::typeof(identity), f, op, a::AcceleratedArray{<:Any,<:Any,<:Any,<:UniqueHashIndex}; kw...)
    return map(inds->@inbounds(reduce(op, a[inds[]]; kw...)), getdict(a.index))
end

function SplitApplyCombine.groupfind(a::AcceleratedArray{<:Any,<:Any,<:Any,<:UniqueHashIndex})
    return getdict(a.index)
end

function SplitApplyCombine._innerjoin!(out, left::AbstractArray, right::AcceleratedArray{<:Any,<:Any,<:Any,<:UniqueHashIndex}, v::AbstractArray, ::typeof(isequal))
    @boundscheck if (axes(left)..., axes(right)...) != axes(v)
        throw(DimensionMismatch("innerjoin arrays do not have matching dimensions"))
    end

    dict = getdict(right.index)

    @inbounds for i_l ∈ keys(left)
        (hasindex, token) = gettoken(dict, left[i_l])
        if hasindex
            i_r = gettokenvalue(dict, token)[]
            push!(out, v[Tuple(i_l)..., Tuple(i_r)...])
        end
    end

    return out
end
