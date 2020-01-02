# Hash table acceleration index
struct HashIndex{D <: HashDictionary} <: AbstractIndex
    dict::D
end

function HashIndex(a::AbstractArray)
    dict = HashDictionary{eltype(a), Vector{eltype(keys(a))}}()
    
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
    (hasindex, token) = gettoken(a.index.dict, f.x)
    if hasindex
        return length(@inbounds gettokenvalue(a.index.dict, token))
    else
        return 0
    end
end

function Base.findall(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:HashIndex})
    (hasindex, token) = gettoken(a.index.dict, f.x)
    if hasindex
        return @inbounds gettokenvalue(a.index.dict, token)
    else
        return Vector{eltype(keys(a))}()
    end
end

# TODO: findall for arbitrary predicates by just checking each unique key? (Sometimes faster, sometimes slower?)

function Base.findfirst(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:HashIndex})
    (hasindex, token) = gettoken(a.index.dict, f.x)
    if hasindex
        return @inbounds first(gettokenvalue(a.index.dict, token))
    else
        return nothing
    end
end

function Base.findlast(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:HashIndex})
    (hasindex, token) = gettoken(a.index.dict, f.x)
    if hasindex
        return @inbounds last(gettokenvalue(a.index.dict, token))
    else
        return nothing
    end
end

function Base.filter(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:HashIndex})
    (hasindex, token) = gettoken(a.index.dict, f.x)
    if hasindex
        return @inbounds parent(a)[(gettokenvalue(a.index.dict, token))]
    else
        return empty(a)
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

function SplitApplyCombine.group(a::AcceleratedArray{<:Any, <:Any, <:Any, <:HashIndex}, b::AbstractArray)
    return map(inds -> @inbounds(b[inds]), a.index.dict)
end

function SplitApplyCombine.groupreduce(op::Callable, a::AcceleratedArray{<:Any, <:Any, <:Any, <:HashIndex}; kw...)
    return map(inds -> @inbounds(reduce(op, view(a, inds); kw...)), a.index.dict)
end

function SplitApplyCombine.groupfind(a::AcceleratedArray{<:Any, <:Any, <:Any, <:HashIndex})
    return a.index.dict
end

function SplitApplyCombine._innerjoin!(out, left::AbstractArray, right::AcceleratedArray{<:Any, <:Any, <:Any, <:HashIndex}, v::AbstractArray, ::typeof(isequal))
    @boundscheck if (axes(left)..., axes(right)...) != axes(v)
        throw(DimensionMismatch("innerjoin arrays do not have matching dimensions"))
    end

    dict = right.index.dict

    @inbounds for i_l ∈ keys(left)
        (hasindex, token) = gettoken(right.index.dict, @inbounds left[i_l])
        if hasindex
            for i_r ∈ gettokenvalue(dict, token)
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
    out = HashDictionary{K, Vector{T}}()
    for a ∈ left
        key = lkey(a)
        group = get!(() -> T[], out, key)
        (hasindex, token) = gettoken(dict, key)
        if hasindex
            for b ∈ @inbounds gettokenvalue(dict, token)
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
