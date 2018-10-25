struct MaybeVector{T} <: AbstractVector{T}
    length::UInt8
    data::T

    MaybeVector{T}() where {T} = new{T}(0x00)
    MaybeVector{T}(x::T) where {T} = new{T}(0x01, x)
end

MaybeVector() = MaybeVector{Any}()
MaybeVector(x::T) where {T} = MaybeVector{T}(x)
MaybeVector{T}(x) where {T} = MaybeVector{T}(convert(T, x))

Base.axes(a::MaybeVector) = (Base.OneTo(a.length),)
Base.size(a::MaybeVector) = (a.length,)
Base.IndexStyle(::Type{<:MaybeVector}) = IndexLinear()
@inline function Base.getindex(a::MaybeVector, i::Integer)
    @boundscheck if a.length != 0x01 || i != 1
        throw(BoundsError(a, i))
    end
    return a.data
end
@inline function Base.getindex(a::MaybeVector)
    @boundscheck if a.length != 0x01
        throw(BoundsError(a, i))
    end
    return a.data
end