struct AcceleratedArray{T, N, A <: AbstractArray{T, N}, I <: AbstractIndex} <: AbstractArray{T, N}
	parent::A
	index::I
end

AcceleratedVector{T, A <: AbstractVector{T}, I <: AbstractIndex} = AcceleratedArray{T, 1, A, I}
AcceleratedMatrix{T, A <: AbstractMatrix{T}, I <: AbstractIndex} = AcceleratedArray{T, 2, A, I}

Base.parent(a::AcceleratedArray) = a.parent
Base.IndexStyle(::Type{AcceleratedArray{<:Any, <:Any, A, <:Any}}) where A = IndexStyle(A)
Base.axes(a::AcceleratedArray) = axes(parent(a))
Base.size(a::AcceleratedArray) = size(parent(a))
@propagate_inbounds Base.getindex(a::AcceleratedArray, i::Int) = getindex(parent(a), i)
@propagate_inbounds function Base.getindex(a::AcceleratedArray{<:Any, N}, inds::Vararg{Int, N}) where {N}
	getindex(parent(a), inds...)
end

function Base.summary(io::IO, a::AcceleratedArray)
	print(io, summary(parent(a)), " + ", summary(a.index))
end

# Disable mutation for now... simplifies the acceleration indices
