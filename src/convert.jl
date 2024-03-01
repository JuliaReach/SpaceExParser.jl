import Base: convert
import SymEngine: convert, free_symbols

"""
   is_linearcombination(L::Basic)

Determine whether the expression `L` is a linear combination of its symbols.

### Input

- `L` -- expression

### Output

`true` if `L` is a linear combination or false otherwise.

### Examples

```jldoctest
julia> using SpaceExParser: is_linearcombination

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
    return all(isempty.(free_symbols.(diff.(L, free_symbols(L)))))
end

is_linearcombination(L::Expr) = is_linearcombination(convert(Basic, L))

"""
    is_halfspace(expr::Expr)

Determine whether the given expression corresponds to a half-space.

### Input

- `expr` -- a symbolic expression

### Output

`true` if `expr` corresponds to a half-space or `false` otherwise.

### Examples

```jldoctest
julia> using SpaceExParser: is_halfspace

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

    # check if the expression defines a half-space
    return is_linearcombination(lhs) && is_linearcombination(rhs)
end

"""
    is_hyperplane(expr::Expr)

Determine whether the given expression corresponds to a hyperplane.

### Input

- `expr` -- a symbolic expression

### Output

`true` if `expr` corresponds to a half-space or `false` otherwise.

### Examples

```jldoctest
julia> using SpaceExParser: is_hyperplane

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

    if :args in fieldnames(typeof(expr.args[2]))
        # treats the 4 in :(2*x1 = 4)
        rhs = convert(Basic, expr.args[2].args[2])
    else
        rhs = convert(Basic, expr.args[2])
    end

    # check if the expression defines a hyperplane
    return is_linearcombination(lhs) && is_linearcombination(rhs)
end

"""
    convert(::Type{HalfSpace{N}}, expr::Expr; vars=nothing) where {N}

Return a `LazySet.HalfSpace` given a symbolic expression that represents a half-space.

### Input

- `expr` -- a symbolic expression
- `vars` -- (optional, default: `nothing`): set of variables with respect to which
            the gradient is taken; if nothing, it takes the free symbols in the given expression

### Output

A `HalfSpace`, in the form `ax <= b`.

### Examples

```jldoctest convert_halfspace
julia> using LazySets: HalfSpace

julia> convert(HalfSpace, :(x1 <= -0.03))
HalfSpace{Float64, Vector{Float64}}([1.0], -0.03)

julia> convert(HalfSpace, :(x1 < -0.03))
HalfSpace{Float64, Vector{Float64}}([1.0], -0.03)

julia> convert(HalfSpace, :(x1 > -0.03))
HalfSpace{Float64, Vector{Float64}}([-1.0], 0.03)

julia> convert(HalfSpace, :(x1 >= -0.03))
HalfSpace{Float64, Vector{Float64}}([-1.0], 0.03)

julia> convert(HalfSpace, :(x1 + x2 <= 2*x4 + 6))
HalfSpace{Float64, Vector{Float64}}([1.0, 1.0, -2.0], 6.0)
```

You can also specify the set of "ambient" variables, even if not
all of them appear:

```jldoctest convert_halfspace
julia> using SymEngine: Basic

julia> convert(HalfSpace, :(x1 + x2 <= 2*x4 + 6), vars=Basic[:x1, :x2, :x3, :x4])
HalfSpace{Float64, Vector{Float64}}([1.0, 1.0, 0.0, -2.0], 6.0)
```
"""
function convert(::Type{HalfSpace{N}}, expr::Expr; vars::Vector{Basic}=Basic[]) where {N}
    @assert is_halfspace(expr) "the expression :(expr) does not correspond to a half-space"

    # check sense of the inequality, assuming < or <= by default
    got_geq = expr.args[1] in [:(>=), :(>)]

    # get sides of the inequality
    lhs, rhs = convert(Basic, expr.args[2]), convert(Basic, expr.args[3])

    # a1 x1 + ... + an xn + K [cmp] 0 for cmp in <, <=, >, >=
    eq = lhs - rhs
    if isempty(vars)
        vars = free_symbols(eq)
    end
    K = subs(eq, [vi => zero(N) for vi in vars]...)
    a = convert(Basic, eq - K)

    # convert to numeric types
    K = convert(N, K)
    a = convert(Vector{N}, diff.(a, vars))

    if got_geq
        return HalfSpace(-a, K)
    else
        return HalfSpace(a, -K)
    end
end

# type-less default half-space conversion
function convert(::Type{HalfSpace}, expr::Expr; vars::Vector{Basic}=Basic[])
    return convert(HalfSpace{Float64}, expr; vars=vars)
end

"""
    convert(::Type{Hyperplane{N}}, expr::Expr; vars=nothing) where {N}

Return a `LazySet.Hyperplane` given a symbolic expression that represents a hyperplane.

### Input

- `expr` -- a symbolic expression
- `vars` -- (optional, default: `nothing`): set of variables with respect to which
            the gradient is taken; if nothing, it takes the free symbols in the given expression

### Output

A `Hyperplane`, in the form `ax = b`.

### Examples

```jldoctest convert_hyperplane
julia> using LazySets: Hyperplane

julia> convert(Hyperplane, :(x1 = -0.03))
Hyperplane{Float64, Vector{Float64}}([1.0], -0.03)

julia> convert(Hyperplane, :(x1 + 0.03 = 0))
Hyperplane{Float64, Vector{Float64}}([1.0], -0.03)

julia> convert(Hyperplane, :(x1 + x2 = 2*x4 + 6))
Hyperplane{Float64, Vector{Float64}}([1.0, 1.0, -2.0], 6.0)
```

You can also specify the set of "ambient" variables in the hyperplane, even if not
all of them appear:

```jldoctest convert_hyperplane
julia> using SymEngine: Basic

julia> convert(Hyperplane, :(x1 + x2 = 2*x4 + 6), vars=Basic[:x1, :x2, :x3, :x4])
Hyperplane{Float64, Vector{Float64}}([1.0, 1.0, 0.0, -2.0], 6.0)
```
"""
function convert(::Type{Hyperplane{N}}, expr::Expr; vars::Vector{Basic}=Basic[]) where {N}
    @assert is_hyperplane(expr) "the expression :(expr) does not correspond to a Hyperplane"

    # get sides of the inequality
    lhs = convert(Basic, expr.args[1])

    # treats the 4 in :(2*x1 = 4)
    rhs = :args in fieldnames(typeof(expr.args[2])) ? convert(Basic, expr.args[2].args[2]) :
          convert(Basic, expr.args[2])

    # a1 x1 + ... + an xn + K = 0
    eq = lhs - rhs
    if isempty(vars)
        vars = free_symbols(eq)
    end
    K = subs(eq, [vi => zero(N) for vi in vars]...)
    a = convert(Basic, eq - K)

    # convert to numeric types
    K = convert(N, K)
    a = convert(Vector{N}, diff.(a, vars))

    return Hyperplane(a, -K)
end

# type-less default Hyperplane conversion
function convert(::Type{Hyperplane}, expr::Expr; vars::Vector{Basic}=Basic[])
    return convert(Hyperplane{Float64}, expr; vars=vars)
end

"""
    free_symbols(expr::Expr, set_type::Type{LazySet})

Return the free symbols in an expression that represents a given set type.

### Input

- `expr` -- symbolic expression

### Output

A list of symbols, in the form of SymEngine `Basic` objects.

### Examples

```jldoctest
julia> using SpaceExParser: free_symbols

julia> using LazySets: HalfSpace

julia> free_symbols(:(x1 <= -0.03), HalfSpace)
1-element Vector{SymEngine.Basic}:
 x1

julia> free_symbols(:(x1 + x2 <= 2*x4 + 6), HalfSpace)
3-element Vector{SymEngine.Basic}:
 x2
 x1
 x4
```
"""
function free_symbols(expr::Expr, ::Type{<:HalfSpace})
    # get sides of the inequality
    lhs, rhs = convert(Basic, expr.args[2]), convert(Basic, expr.args[3])
    return free_symbols(lhs - rhs)
end

function free_symbols(expr::Expr, ::Type{<:Hyperplane})
    # get sides of the inequality
    lhs = convert(Basic, expr.args[1])

    # treats the 4 in :(2*x1 = 4)
    rhs = :args in fieldnames(typeof(expr.args[2])) ? convert(Basic, expr.args[2].args[2]) :
          convert(Basic, expr.args[2])
    return free_symbols(lhs - rhs)
end

function free_symbols(expr::Expr)
    if is_hyperplane(expr)
        return free_symbols(expr, HyperPlane)
    elseif is_halfspace(expr)
        return free_symbols(expr, Halfspace)
    else
        error("the free symbols for the expression $(expr) is not implemented")
    end
end
