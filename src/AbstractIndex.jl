abstract type AbstractIndex; end

"""
    accelerate(a, IndexType)

Return an `AcceleratedArray` wrapping `a` using the acceleration index of type `T`.

This operation will not modify `a` but the acceleration index will be invalidated (and
become unsafe to use) if `a` is modified directly after the index is constructed. (See also
`accelerate!`).
"""
function accelerate(a::AbstractArray, ::Type{T}) where {T <: AbstractIndex}
	AcceleratedArray(a, T(a))
end

"""
    accelerate!(a, IndexType)

Return an `AcceleratedArray` wrapping `a` using the acceleration index of type `T`.

Depending on the index type, this operation may also modify `a`. For example a `SortIndex`
will `sort!` the array `a` to maximize cache efficiency. The acceleration index will be
invalidated (and become unsafe to use) if `a` is modified directly after the index is
constructed. (See also `accelerate`).
"""
function accelerate!(a::AbstractArray, ::Type{T}) where {T <: AbstractIndex}
	accelerate(a, T)
end