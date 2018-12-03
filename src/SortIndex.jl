struct SortIndex{O <: AbstractVector} <: AbstractIndex
	n_unique::Int
	order::O
end

function accelerate(a::AbstractArray, ::Type{SortIndex})
    order = sortperm(a)
    n_unique = min(1, length(order))
    @inbounds for i in firstindex(order)+1:lastindex(order)
    	n_unique += !isequal(a[order[i]], a[order[i-1]])
    end
    return AcceleratedArray(a, SortIndex(n_unique, order))
end

function accelerate!(a::AbstractArray, ::Type{SortIndex})
    sort!(a)
    n_unique = min(1, length(a))
    @inbounds for i in firstindex(a)+1:lastindex(a)
    	n_unique += !isequal(a[i], a[i-1])
    end
    return AcceleratedArray(a, SortIndex(n_unique, keys(a)))
end

Base.summary(s::SortIndex) = "SortIndex ($(s.n_unique) unique element$(s.n_unique == 1 ? "" : "s"))"

# Accelerations
function Base.in(x, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    count(isequal(x), a) > 0
end


function Base.count(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    @inbounds length(searchsorted(view(parent(a), a.index.order), f.x))
end

function Base.count(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex{<:LinearIndices}})
    @inbounds length(searchsorted(parent(a), f.x))
end

function Base.count(f::Fix2{typeof(isless)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    min(lastindex(a.index.order), searchsortedlastless(@inbounds(view(parent(a), a.index.order)), f.x)) - firstindex(a.index.order) + 1
end

function Base.count(f::Fix2{typeof(isless)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex{<:LinearIndices}})
    min(lastindex(parent(a)), searchsortedlastless(parent(a), f.x)) - firstindex(parent(a)) + 1
end

function Base.count(f::Fix2{typeof(islessequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    min(lastindex(a.index.order), searchsortedlast(@inbounds(view(parent(a), a.index.order)), f.x)) - firstindex(a.index.order) + 1
end

function Base.count(f::Fix2{typeof(islessequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex{<:LinearIndices}})
    min(lastindex(parent(a)), searchsortedlast(parent(a), f.x)) - firstindex(parent(a)) + 1
end

function Base.count(f::Fix2{typeof(isgreater)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    lastindex(a.index.order) - max(firstindex(a.index.order), searchsortedfirstgreater(@inbounds(view(parent(a), a.index.order)), f.x)) + 1
end

function Base.count(f::Fix2{typeof(isgreater)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex{<:LinearIndices}})
    lastindex(parent(a)) - max(firstindex(parent(a)), searchsortedfirstgreater(parent(a), f.x)) + 1
end

function Base.count(f::Fix2{typeof(isgreaterequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    lastindex(a.index.order) - max(firstindex(a.index.order), searchsortedfirst(@inbounds(view(parent(a), a.index.order)), f.x)) + 1
end

function Base.count(f::Fix2{typeof(isgreaterequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex{<:LinearIndices}})
    lastindex(parent(a)) - max(firstindex(parent(a)), searchsortedfirst(parent(a), f.x)) + 1
end

function Base.count(f::Fix2{typeof(in), <:Interval}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    @inbounds min(lastindex(a.index.order), searchsortedlast(view(parent(a), a.index.order), f.x.stop)) - max(firstindex(a.index.order), searchsortedfirst(view(parent(a), a.index.order), f.x.start)) + 1
end

function Base.count(f::Fix2{typeof(in), <:Interval}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex{<:LinearIndices}})
    @inbounds min(lastindex(parent(a)), searchsortedlast(parent(a), f.x.stop)) - max(firstindex(parent(a)), searchsortedfirst(parent(a), f.x.start)) + 1
end


function Base.findall(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    @inbounds a.index.order[searchsorted(view(parent(a), a.index.order), f.x)]
end

function Base.findall(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex{<:LinearIndices}})
    @inbounds searchsorted(parent(a), f.x)
end

function Base.findall(f::Fix2{typeof(isless)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    @inbounds a.index.order[firstindex(a.index.order) : min(lastindex(a.index.order), searchsortedlastless(view(parent(a), a.index.order), f.x))]
end

function Base.findall(f::Fix2{typeof(isless)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex{<:LinearIndices}})
    @inbounds firstindex(parent(a)) : min(lastindex(parent(a)), searchsortedlastless(parent(a), f.x))
end

function Base.findall(f::Fix2{typeof(islessequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    @inbounds a.index.order[firstindex(a.index.order) : min(lastindex(a.index.order), searchsortedlast(view(parent(a), a.index.order), f.x))]
end

function Base.findall(f::Fix2{typeof(islessequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex{<:LinearIndices}})
    @inbounds firstindex(parent(a)) : min(lastindex(parent(a)), searchsortedlast(parent(a), f.x))
end

function Base.findall(f::Fix2{typeof(isgreater)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    @inbounds a.index.order[max(firstindex(a.index.order), searchsortedfirstgreater(view(parent(a), a.index.order), f.x)) : lastindex(a.index.order)]
end

function Base.findall(f::Fix2{typeof(isgreater)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex{<:LinearIndices}})
    @inbounds max(firstindex(parent(a)), searchsortedfirstgreater(parent(a), f.x)) : lastindex(parent(a))
end

function Base.findall(f::Fix2{typeof(isgreaterequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    @inbounds a.index.order[max(firstindex(a.index.order), searchsortedfirst(view(parent(a), a.index.order), f.x)) : lastindex(a.index.order)]
end

function Base.findall(f::Fix2{typeof(isgreaterequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex{<:LinearIndices}})
    @inbounds max(firstindex(parent(a)), searchsortedfirst(parent(a), f.x)) : lastindex(parent(a))
end

function Base.findall(f::Fix2{typeof(in), <:Interval}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    @inbounds a.index.order[max(firstindex(a.index.order), searchsortedfirst(view(parent(a), a.index.order), f.x.start)) : min(lastindex(a.index.order), searchsortedlast(view(parent(a), a.index.order), f.x.stop))]
end

function Base.findall(f::Fix2{typeof(in), <:Interval}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex{<:LinearIndices}})
    @inbounds max(firstindex(parent(a)), searchsortedfirst(parent(a), f.x.start)) : min(lastindex(parent(a)), searchsortedlast(parent(a), f.x.stop))
end


function Base.filter(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    @inbounds parent(a)[view(a.index.order, searchsorted(view(parent(a), a.index.order), f.x))]
end

function Base.filter(f::Fix2{typeof(isequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex{<:LinearIndices}})
    @inbounds parent(a)[searchsorted(parent(a), f.x)]
end

function Base.filter(f::Fix2{typeof(isless)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    @inbounds parent(a)[a.index.order[firstindex(a.index.order) : min(lastindex(a.index.order), searchsortedlastless(view(parent(a), a.index.order), f.x))]]
end

function Base.filter(f::Fix2{typeof(isless)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex{<:LinearIndices}})
    @inbounds parent(a)[firstindex(parent(a)) : min(lastindex(parent(a)), searchsortedlastless(parent(a), f.x))]
end

function Base.filter(f::Fix2{typeof(islessequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    @inbounds parent(a)[a.index.order[firstindex(a.index.order) : min(lastindex(a.index.order), searchsortedlast(view(parent(a), a.index.order), f.x))]]
end

function Base.filter(f::Fix2{typeof(islessequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex{<:LinearIndices}})
    @inbounds parent(a)[firstindex(parent(a)) : min(lastindex(parent(a)), searchsortedlast(parent(a), f.x))]
end

function Base.filter(f::Fix2{typeof(isgreater)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    @inbounds parent(a)[a.index.order[max(firstindex(a.index.order), searchsortedfirstgreater(view(parent(a), a.index.order), f.x)) : lastindex(a.index.order)]]
end

function Base.filter(f::Fix2{typeof(isgreater)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex{<:LinearIndices}})
    @inbounds parent(a)[max(firstindex(parent(a)), searchsortedfirstgreater(parent(a), f.x)) : lastindex(parent(a))]
end

function Base.filter(f::Fix2{typeof(isgreaterequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    @inbounds parent(a)[a.index.order[max(firstindex(a.index.order), searchsortedfirst(view(parent(a), a.index.order), f.x)) : lastindex(a.index.order)]]
end

function Base.filter(f::Fix2{typeof(isgreaterequal)}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex{<:LinearIndices}})
    @inbounds parent(a)[max(firstindex(parent(a)), searchsortedfirst(parent(a), f.x)) : lastindex(parent(a))]
end

function Base.filter(f::Fix2{typeof(in), <:Interval}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    @inbounds parent(a)[a.index.order[max(firstindex(a.index.order), searchsortedfirst(view(parent(a), a.index.order), f.x.start)) : min(lastindex(a.index.order), searchsortedlast(view(parent(a), a.index.order), f.x.stop))]]
end

function Base.filter(f::Fix2{typeof(in), <:Interval}, a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex{<:LinearIndices}})
    @inbounds parent(a)[max(firstindex(parent(a)), searchsortedfirst(parent(a), f.x.start)) : min(lastindex(parent(a)), searchsortedlast(parent(a), f.x.stop))]
end

function Base.unique(a::AcceleratedArray{<:Any, <:Any, <:Any, <:SortIndex})
    p = parent(a)
    b = Vector{eltype(a)}() # Require that push! works, which `empty` and `similar` don't guarantee
    o = a.index.order
    
    s = iterate(o)
    if s === nothing
        return AcceleratedArray(b, UniqueSortIndex(0, keys(b)))
    end

    (i, it) = s
    last = @inbounds p[i]
    push!(b, last)

    s = iterate(o, it)
    while s !== nothing
        (i, it) = s
        this = @inbounds p[i]
        if isequal(this, last)
            s = iterate(o, it)
            continue
        end
        push!(b, this)
        last = this
        s = iterate(o, it)
    end

    return AcceleratedArray(b, UniqueSortIndex(keys(b)))
end
