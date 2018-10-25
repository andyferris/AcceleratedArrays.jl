struct SingleVector{T} <: AbstractVector{T}
    data::T
end

Base.axes(a::SingleVector) = (Base.OneTo(1),)
Base.size(a::SingleVector) = (1,)
Base.IndexStyle(::Type{<:SingleVector}) = IndexLinear()
@inline function Base.getindex(a::SingleVector, i::Integer)
    @boundscheck if i != 1
        throw(BoundsError(a, i))
    end
    return a.data
end

Base.getindex(a::SingleVector) = a.data