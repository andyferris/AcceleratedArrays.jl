abstract type AbstractUniqueIndex <: AbstractIndex; end

Base.unique(a::AcceleratedArray{<:Any, <:Any, <:Any, <:AbstractUniqueIndex}) = a
