
struct UniqueSortIndex{O <: AbstractVector} <: AbstractUniqueIndex
	order::O
end

function accelerate(a::AbstractArray, ::Type{UniqueSortIndex})
    order = sortperm(a)
    @inbounds for i in firstindex(order)+1:lastindex(order)
	    if isequal(a[order[i]], a[order[i-1]])
	    	error("Input not unique")
	    end
	end
    return AcceleratedArray(a, UniqueSortIndex(order))
end

function accelerate!(a::AbstractArray, ::Type{UniqueSortIndex})
    sort!(a)
    @inbounds for i in firstindex(a)+1:lastindex(a)
	    if isequal(a[i], a[i-1])
	    	error("Input not unique")
	    end
	end
    return AcceleratedArray(a, UniqueSortIndex(keys(a)))
end

Base.summary(::UniqueSortIndex) = "UniqueSortIndex"

# Accelerations
function Base.in(x, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
    count(isequal(x), a) > 0
end


function Base.count(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
	i = searchsortedfirst(@inbounds(view(parent(a), a.index.order)), f.x)
	@inbounds return i <= lastindex(a.index.order) && f(parent(a)[a.index.order[i]])
end

function Base.count(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
	i = searchsortedfirst(parent(a), f.x)
	@inbounds return i <= lastindex(parent(a)) && f(parent(a)[i])
end

function Base.count(f::Fix2{typeof(isless)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
    min(lastindex(a.index.order), searchsortedlastless(@inbounds(view(parent(a), a.index.order)), f.x)) - firstindex(a.index.order) + 1
end

function Base.count(f::Fix2{typeof(isless)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    min(lastindex(parent(a)), searchsortedlastless(parent(a), f.x)) - firstindex(parent(a)) + 1
end

function Base.count(f::Fix2{typeof(islessequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
    min(lastindex(a.index.order), searchsortedlast(@inbounds(view(parent(a), a.index.order)), f.x)) - firstindex(a.index.order) + 1
end

function Base.count(f::Fix2{typeof(islessequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    min(lastindex(parent(a)), searchsortedlast(parent(a), f.x)) - firstindex(parent(a)) + 1
end

function Base.count(f::Fix2{typeof(isgreater)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
    lastindex(a.index.order) - max(firstindex(a.index.order), searchsortedfirstgreater(@inbounds(view(parent(a), a.index.order)), f.x)) + 1
end

function Base.count(f::Fix2{typeof(isgreater)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    lastindex(parent(a)) - max(firstindex(parent(a)), searchsortedfirstgreater(parent(a), f.x)) + 1
end

function Base.count(f::Fix2{typeof(isgreaterequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
    lastindex(a.index.order) - max(firstindex(a.index.order), searchsortedfirst(@inbounds(view(parent(a), a.index.order)), f.x)) + 1
end

function Base.count(f::Fix2{typeof(isgreaterequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    lastindex(parent(a)) - max(firstindex(parent(a)), searchsortedfirst(parent(a), f.x)) + 1
end

function Base.count(f::Fix2{typeof(in), <:Interval}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
    @inbounds min(lastindex(a.index.order), searchsortedlast(view(parent(a), a.index.order), f.x.stop)) - max(firstindex(a.index.order), searchsortedfirst(view(parent(a), a.index.order), f.x.start)) + 1
end

function Base.count(f::Fix2{typeof(in), <:Interval}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    @inbounds min(lastindex(parent(a)), searchsortedlast(parent(a), f.x.stop)) - max(firstindex(parent(a)), searchsortedfirst(parent(a), f.x.start)) + 1
end


function Base.findall(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
	i = searchsortedfirst(@inbounds(view(parent(a), a.index.order)), f.x)
	@inbounds if i > lastindex(a.index.order) || !f(parent(a)[a.index.order[i]])
	    return MaybeVector{eltype(a.index.order)}()
	else
		return MaybeVector(a.index.order[i])
	end
end

function Base.findall(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
	i = searchsortedfirst(parent(a), f.x)
	@inbounds if i > lastindex(parent(a)) || !f(parent(a)[i])
	    return MaybeVector{typeof(i)}()
	else
		return MaybeVector(i)
	end
end

function Base.findall(f::Fix2{typeof(isless)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
    @inbounds a.index.order[firstindex(a.index.order) : min(lastindex(a.index.order), searchsortedlastless(view(parent(a), a.index.order), f.x))]
end

function Base.findall(f::Fix2{typeof(isless)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    @inbounds firstindex(parent(a)) : min(lastindex(parent(a)), searchsortedlastless(parent(a), f.x))
end

function Base.findall(f::Fix2{typeof(islessequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
    @inbounds a.index.order[firstindex(a.index.order) : min(lastindex(a.index.order), searchsortedlast(view(parent(a), a.index.order), f.x))]
end

function Base.findall(f::Fix2{typeof(islessequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    @inbounds firstindex(parent(a)) : min(lastindex(parent(a)), searchsortedlast(parent(a), f.x))
end

function Base.findall(f::Fix2{typeof(isgreater)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
    @inbounds a.index.order[max(firstindex(a.index.order), searchsortedfirstgreater(view(parent(a), a.index.order), f.x)) : lastindex(a.index.order)]
end

function Base.findall(f::Fix2{typeof(isgreater)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    @inbounds max(firstindex(parent(a)), searchsortedfirstgreater(parent(a), f.x)) : lastindex(parent(a))
end

function Base.findall(f::Fix2{typeof(isgreaterequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
    @inbounds a.index.order[max(firstindex(a.index.order), searchsortedfirst(view(parent(a), a.index.order), f.x)) : lastindex(a.index.order)]
end

function Base.findall(f::Fix2{typeof(isgreaterequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    @inbounds max(firstindex(parent(a)), searchsortedfirst(parent(a), f.x)) : lastindex(parent(a))
end

function Base.findall(f::Fix2{typeof(in), <:Interval}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
    @inbounds a.index.order[max(firstindex(a.index.order), searchsortedfirst(view(parent(a), a.index.order), f.x.start)) : min(lastindex(a.index.order), searchsortedlast(view(parent(a), a.index.order), f.x.stop))]
end

function Base.findall(f::Fix2{typeof(in), <:Interval}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    @inbounds max(firstindex(parent(a)), searchsortedfirst(parent(a), f.x.start)) : min(lastindex(parent(a)), searchsortedlast(parent(a), f.x.stop))
end


function Base.filter(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
    i = searchsortedfirst(@inbounds(view(parent(a), a.index.order)), f.x)
	if i > lastindex(a.index.order)
		return MaybeVector{eltype(a)}()
	end
	x = @inbounds a[a.index.order[i]]
	return f(x) ? MaybeVector(x) : MaybeVector{eltype(a)}()
end

function Base.filter(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
	i = searchsortedfirst(parent(a), f.x)
	if i > lastindex(parent(a))
		return MaybeVector{eltype(a)}()
	end
	x = @inbounds a[i]
	return f(x) ? MaybeVector(x) : MaybeVector{eltype(a)}()
end

function Base.filter(f::Fix2{typeof(isless)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
    @inbounds parent(a)[a.index.order[firstindex(a.index.order) : min(lastindex(a.index.order), searchsortedlastless(view(parent(a), a.index.order), f.x))]]
end

function Base.filter(f::Fix2{typeof(isless)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    @inbounds parent(a)[firstindex(parent(a)) : min(lastindex(parent(a)), searchsortedlastless(parent(a), f.x))]
end

function Base.filter(f::Fix2{typeof(islessequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
    @inbounds parent(a)[a.index.order[firstindex(a.index.order) : min(lastindex(a.index.order), searchsortedlast(view(parent(a), a.index.order), f.x))]]
end

function Base.filter(f::Fix2{typeof(islessequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    @inbounds parent(a)[firstindex(parent(a)) : min(lastindex(parent(a)), searchsortedlast(parent(a), f.x))]
end

function Base.filter(f::Fix2{typeof(isgreater)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
    @inbounds parent(a)[a.index.order[max(firstindex(a.index.order), searchsortedfirstgreater(view(parent(a), a.index.order), f.x)) : lastindex(a.index.order)]]
end

function Base.filter(f::Fix2{typeof(isgreater)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    @inbounds parent(a)[max(firstindex(parent(a)), searchsortedfirstgreater(parent(a), f.x)) : lastindex(parent(a))]
end

function Base.filter(f::Fix2{typeof(isgreaterequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
    @inbounds parent(a)[a.index.order[max(firstindex(a.index.order), searchsortedfirst(view(parent(a), a.index.order), f.x)) : lastindex(a.index.order)]]
end

function Base.filter(f::Fix2{typeof(isgreaterequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    @inbounds parent(a)[max(firstindex(parent(a)), searchsortedfirst(parent(a), f.x)) : lastindex(parent(a))]
end

function Base.filter(f::Fix2{typeof(in), <:Interval}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
    @inbounds parent(a)[a.index.order[max(firstindex(a.index.order), searchsortedfirst(view(parent(a), a.index.order), f.x.start)) : min(lastindex(a.index.order), searchsortedlast(view(parent(a), a.index.order), f.x.stop))]]
end

function Base.filter(f::Fix2{typeof(in), <:Interval}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    @inbounds parent(a)[max(firstindex(parent(a)), searchsortedfirst(parent(a), f.x.start)) : min(lastindex(parent(a)), searchsortedlast(parent(a), f.x.stop))]
end


# We mostly accelerate these where the array order is sorted - exhaustive search of matching
# indices could be slower than starting at the beginning of the array,
function Base.findfirst(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
    i = searchsortedfirst(@inbounds(view(parent(a), a.index.order)), f.x)
    @inbounds if i > lastindex(a.index.order) || !f(parent(a)[a.index.order[i]])
        return nothing
    else
        return a.index.order[i]
    end
end

function Base.findfirst(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    i = searchsortedfirst(parent(a), f.x)
    @inbounds if i > lastindex(parent(a)) || !f(parent(a)[i])
        return nothing
    else
        return i
    end
end

function Base.findfirst(f::Fix2{typeof(isless)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    if isempty(a.parent) || !f(first(a))
        return nothing
    else
        return firstindex(a.parent)
    end
end

function Base.findfirst(f::Fix2{typeof(islessequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    if isempty(a.parent) || !f(first(a))
        return nothing
    else
        return firstindex(a.parent)
    end
end

function Base.findfirst(f::Fix2{typeof(isgreater)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    i = searchsortedfirstgreater(parent(a), f.x)
    @inbounds if i > lastindex(parent(a)) || !f(parent(a)[i])
        return nothing
    else
        return i
    end
end

function Base.findfirst(f::Fix2{typeof(isgreaterequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    i = searchsortedfirst(parent(a), f.x)
    @inbounds if i > lastindex(parent(a)) || !f(parent(a)[i])
        return nothing
    else
        return i
    end
end

function Base.findfirst(f::Fix2{typeof(in), <:Interval}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    i = searchsortedfirst(parent(a), f.x.start)
    @inbounds if i > lastindex(parent(a)) || !f(parent(a)[i])
        return nothing
    else
        return i
    end
end


# We mostly accelerate these where the array order is sorted
function Base.findlast(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex})
    i = searchsortedlast(@inbounds(view(parent(a), a.index.order)), f.x)
    @inbounds if i < firstindex(a.index.order) || !f(parent(a)[a.index.order[i]])
        return nothing
    else
        return a.index.order[i]
    end
end

function Base.findlast(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    i = searchsortedlast(parent(a), f.x)
    @inbounds if i < firstindex(parent(a)) || !f(parent(a)[i])
        return nothing
    else
        return i
    end
end

function Base.findlast(f::Fix2{typeof(isless)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    i = searchsortedlastless(parent(a), f.x)
    @inbounds if i < firstindex(parent(a)) || !f(parent(a)[i])
        return nothing
    else
        return i
    end
end

function Base.findlast(f::Fix2{typeof(islessequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    i = searchsortedlast(parent(a), f.x)
    @inbounds if i < firstindex(parent(a)) || !f(parent(a)[i])
        return nothing
    else
        return i
    end
end

function Base.findlast(f::Fix2{typeof(isgreater)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    if isempty(a.parent) || !f(last(a))
        return nothing
    else
        return lastindex(a.parent)
    end
end

function Base.findlast(f::Fix2{typeof(isgreaterequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    if isempty(a.parent) || !f(last(a))
        return nothing
    else
        return lastindex(a.parent)
    end
end

function Base.findlast(f::Fix2{typeof(in), <:Interval}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:UniqueSortIndex{<:LinearIndices}})
    i = searchsortedlast(parent(a), f.x.stop)
    @inbounds if i < firstindex(parent(a)) || !f(parent(a)[i])
        return nothing
    else
        return i
    end
end

# TODO - Grouping
#      - Sort-merge joins
#      - Sorted indexing preserves sortedness (including at least unit ranges)
