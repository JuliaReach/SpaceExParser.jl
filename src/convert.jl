import Base.convert, SymEngine.convert

"""
   is_linearcombination(L::Basic)

Return `true` whether the expression `L` is a linear combination of its symbols.
"""
function is_linearcombination(L::Basic)
    all(isempty.(free_symbols.(diff.(L, free_symbols(L)))))
end

"""
    is_hyperplane(expr::Expr)

Return wheter the given expression correspond to a hyperplane.

### Input

- `expr` -- a symbolic expression

### Output

`true` if `expr` corresponds to a hyperplane or `false` otherwise.

### Examples

```jldoctest
julia> all(is_hyperplane.([:(x1 <= 0), :(x1 < 0), :(x1 > 0), :(x1 >= 0)]))
true

julia> is_hyperplane(:(2*x1 <= 4))
true

julia> is_hyperplane(:(6.1 <= 5.3*f - 0.1*g))
true

julia> is_hyperplane(:(2*x1^2 <= 4))
false

julia> is_hyperplane(:(x1^2 > 4*x2 - x3))
false

julia> is_hyperplane(:(x1 > 4*x2 - x3))
true
```
"""
function is_hyperplane(expr::Expr)::Bool

    # check that there are three arguments
    # these are the comparison symbol, the left hand side and the right hand side
    if length(expr.args) != 3
        return false
    end

    # check that this is an inequality
    if !(expr.args[1] in [:(<=), :(<), :(>=), :(>)])
        return false
    end

    # convert to symengine expressions
    lhs, rhs = convert(Basic, expr.args[2]), convert(Basic, expr.args[3])

    # check if the expression defines a hyplerplane
    if !is_linearcombination(lhs)
        return false
    elseif !is_linearcombination(rhs)
        return false
    else
        return true
    end
end
