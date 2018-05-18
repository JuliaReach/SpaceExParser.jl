import Base.convert, SymEngine.convert

"""
   is_linearcombination(L::Basic)

Return whether the expression `L` is a linear combination of its symbols.

### Input

- `L` -- expression

### Output

`true` if `L` is a linear combination or false otherwise.

### Examples

```jldoctest
julia> import SX.is_linearcombination

julia> is_linearcombination(:(2*x1 - 4))
true

julia> is_linearcombination(:(6.1 - 5.3*f - 0.1*g))
true

julia> is_linearcombination(:(2*x1^2))
false

julia> is_linearcombination(:(x1^2 - 4*x2 + x3 + 2))
false
```
"""
function is_linearcombination(L::Basic)
    all(isempty.(free_symbols.(diff.(L, free_symbols(L)))))
end

is_linearcombination(L::Expr) = is_linearcombination(convert(Basic, L))

"""
    is_halfspace(expr::Expr)

Return wheter the given expression corresponds to a halfspace.

### Input

- `expr` -- a symbolic expression

### Output

`true` if `expr` corresponds to a halfspace or `false` otherwise.

### Examples

```jldoctest
julia> import SX.is_halfspace

julia> all(is_halfspace.([:(x1 <= 0), :(x1 < 0), :(x1 > 0), :(x1 >= 0)]))
true

julia> is_halfspace(:(2*x1 <= 4))
true

julia> is_halfspace(:(6.1 <= 5.3*f - 0.1*g))
true

julia> is_halfspace(:(2*x1^2 <= 4))
false

julia> is_halfspace(:(x1^2 > 4*x2 - x3))
false

julia> is_halfspace(:(x1 > 4*x2 - x3))
true
```
"""
function is_halfspace(expr::Expr)::Bool

    # check that there are three arguments
    # these are the comparison symbol, the left hand side and the right hand side
    if (length(expr.args) != 3) || !(expr.head == :call)
        return false
    end

    # check that this is an inequality
    if !(expr.args[1] in [:(<=), :(<), :(>=), :(>)])
        return false
    end

    # convert to symengine expressions
    lhs, rhs = convert(Basic, expr.args[2]), convert(Basic, expr.args[3])

    # check if the expression defines a halfspace
    if is_linearcombination(lhs) && is_linearcombination(rhs)
        return true
    else
        return false
    end
end

"""
    is_hyperplane(expr::Expr)

Return wheter the given expression corresponds to a hyperplane.

### Input

- `expr` -- a symbolic expression

### Output

`true` if `expr` corresponds to a halfspace or `false` otherwise.

### Examples

```jldoctest
julia> import SX.is_hyperplane

julia> is_hyperplane(:(x1 = 0))
true

julia> is_hyperplane(:(2*x1 = 4))
true

julia> is_hyperplane(:(6.1 = 5.3*f - 0.1*g))
true

julia> is_hyperplane(:(2*x1^2 = 4))
false

julia> is_hyperplane(:(x1^2 = 4*x2 - x3))
false

julia> is_hyperplane(:(x1 = 4*x2 - x3))
true
```
"""
function is_hyperplane(expr::Expr)::Bool

    # check that there are three arguments
    # these are the comparison symbol, the left hand side and the right hand side
    if (length(expr.args) != 2) || !(expr.head == :(=))
        return false
    end

    # convert to symengine expressions
    lhs = convert(Basic, expr.args[1])

    if :args in fieldnames(expr.args[2])
        # treats the 4 in :(2*x1 = 4)
        rhs = convert(Basic, expr.args[2].args[2])
    else
        rhs = convert(Basic, expr.args[2])
    end

    # check if the expression defines a hyperplane
    if is_linearcombination(lhs) && is_linearcombination(rhs)
        return true
    else
        return false
    end
end
