# Hash table acceleration index
struct UniqueHashIndex{D <: Dict} <: AbstractUniqueIndex
    dict::D
end 

function UniqueHashIndex(a::AbstractArray)
	dict = Dict{eltype(a), eltype(keys(a))}()

    @inbounds for i in keys(a)
        value = a[i]
        index = Base.ht_keyindex2!(dict, value)
	    if index > 0 # `value` found in `dict`
	        error("Input not unique") # TODO Use appropriate Exception
	    else # `value` is ready to be inserted into `dict` at slot `-index`
	        @inbounds Base._setindex!(dict, i, value, -index)
	    end
    end
    return UniqueHashIndex(dict)
end

Base.summary(::UniqueHashIndex) = "UniqueHashIndex"

# Accelerations
function Base.findall(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueHashIndex})
	index = Base.ht_keyindex(a.index.dict, f.x)
	if index < 0
		return MaybeVector{eltype(keys(a))}()
	else
		return MaybeVector(@inbounds a.index.dict.vals[index])
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
