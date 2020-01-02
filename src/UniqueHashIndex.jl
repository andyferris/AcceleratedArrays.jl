# Hash table acceleration index
struct UniqueHashIndex{D <: HashDictionary} <: AbstractUniqueIndex
    dict::D
end 

function UniqueHashIndex(a::AbstractArray)
    dict = HashDictionary{eltype(a), SingleVector{eltype(keys(a))}}()

    @inbounds for i in keys(a)
        value = a[i]
        (hadindex, token) = gettoken!(dict, value)
        if hadindex
            error("Input not unique") # TODO Use appropriate Exception
        else # `value` is ready to be inserted into `dict` at slot `-index`
            @inbounds settokenvalue!(dict, token, SingleVector(i))
        end
    end
    return UniqueHashIndex(dict)
end

Base.summary(::UniqueHashIndex) = "UniqueHashIndex"

# Accelerations
Base.in(x, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueHashIndex}) = haskey(a.index.dict, x)

function Base.count(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueHashIndex})
    if f.x in keys(a.index.dict)
        return 1
    else
        return 0
    end
end

function Base.findall(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueHashIndex})
    (hasindex, token) = gettoken(a.index.dict, f.x)
    if hasindex
        return MaybeVector(@inbounds gettokenvalue(a.index.dict, token)[])
    else
        return MaybeVector{eltype(keys(a))}()
    end
end

function Base.filter(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueHashIndex})
    if f.x in keys(a.index.dict)
        return MaybeVector{eltype(a)}(f.x)
    else
        return MaybeVector{eltype(a)}()
    end
end

function SplitApplyCombine.group(a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueHashIndex}, b::AbstractArray)
    return map(inds -> SingleVector(@inbounds b[inds[]]), a.index.dict)
end

function SplitApplyCombine.groupreduce(::typeof(identity), f, op, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueHashIndex}; kw...)
    return map(inds -> @inbounds(reduce(op, a[inds[]]; kw...)), a.index.dict)
end

function SplitApplyCombine.groupfind(a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueHashIndex})
    return a.index.dict
end

function SplitApplyCombine._innerjoin!(out, left::AbstractArray, right::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueHashIndex}, v::AbstractArray, ::typeof(isequal))
    @boundscheck if (axes(left)..., axes(right)...) != axes(v)
        throw(DimensionMismatch("innerjoin arrays do not have matching dimensions"))
    end

    dict = right.index.dict

    @inbounds for i_l ∈ keys(left)
        (hasindex, token) = gettoken(dict, left[i_l])
        if hasindex
            i_r = gettokenvalue(dict, token)[]
            push!(out, v[Tuple(i_l)..., Tuple(i_r)...])
        end
    end

    return out
end
