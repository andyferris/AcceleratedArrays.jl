# Some predicates which are "missing" from Base
Base.isless(x) = Fix2(isless, x)
Base.:(<)(x) = Fix2(<, x)
Base.:(<=)(x) = Fix2(<=, x)
Base.:(>)(x) = Fix2(>, x)
Base.:(>=)(x) = Fix2(>=, x)
Base.:(!=)(x) = Fix2(!=, x)
