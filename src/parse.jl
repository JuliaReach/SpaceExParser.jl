const _parse_s = Base.Meta.parse
const _parse_t = Base.parse

"""
    count_locations_and_transitions(root_sxmodel)

Returns the number of locations and transitions for each component.

### Input

- `root_sxmodel` -- the root element of a SpaceEx file

### Output

Two vectors of integers `(lcount, tcount)`, where the i-th entry of `lcount` and
`tcount` are the number of locations and transitions, respectively, of the i-th component.
"""
function count_locations_and_transitions(root_sxmodel)
    lcount = Vector{Int}() # num locations for each component
    tcount = Vector{Int}() # num transitions for each component
    id_component = 0 # index of the current component

    for component in eachelement(root_sxmodel)
        if nodename(component) == "component"
            id_component += 1
            push!(lcount, 0)
            push!(tcount, 0)
            for field in eachelement(component)
                if nodename(field) == "location"
                    lcount[id_component] += 1
                elseif nodename(field) == "transition"
                    tcount[id_component] += 1
                end
            end
        end
    end
    return (lcount, tcount)
end

"""
    parse_sxmath(s; assignment=false)

Returns the list of expressions corresponding to a given SpaceExParser string.

### Input

- `s`          -- string
- `assignment` -- (optional, default: `false`)

### Output

Vector of expressions, equations or inequalities.

### Examples

```jldoctest parse_sxmath
julia> using SpaceExParser: parse_sxmath

julia> parse_sxmath("x >= 0")
1-element Vector{Expr}:
 :(x >= 0)

julia> parse_sxmath("x' == x & v' == -0.75*v")
2-element Vector{Expr}:
 :(x' = x)
 :(v' = -0.75v)

julia> parse_sxmath("x == 0 & v <= 0")
2-element Vector{Expr}:
 :(x = 0)
 :(v <= 0)
```

Parentheses are ignored:

```jldoctest parse_sxmath
julia> parse_sxmath("(x == 0) & (v <= 0)")
2-element Vector{Expr}:
 :(x = 0)
 :(v <= 0)
```

Splitting is also performend over double ampersand symbols:

```jldoctest parse_sxmath
julia> parse_sxmath("x == 0 && v <= 0")
2-element Vector{Expr}:
 :(x = 0)
 :(v <= 0)
```

If you want to parse an assignment, use the `assignment` flag:

```jldoctest parse_sxmath
julia> parse_sxmath("x := -x*0.1", assignment=true)
1-element Vector{Expr}:
 :(x = -x * 0.1)
```

 Check that we can parse expressions involving parentheses:

```jldoctest parse_sxmath
julia> parse_sxmath("(t <= 125 & y>= -100)")
2-element Vector{Expr}:
 :(t <= 125)
 :(y >= -100)
julia> parse_sxmath("t <= 125 & (y>= -100)")
2-element Vector{Expr}:
 :(t <= 125)
 :(y >= -100)
```

### Algorithm

First a sanity check (assertion) is made that the expression makes a coherent use
of parentheses.

Then, the following steps are done (in the given order):

- split the string with the `&` key, or `&&`
- remove trailing whitespace of each substring
- replace double `==` with single `=`
- detect unbalanced parentheses (beginning and final subexpressions) and in that case delete them
- cast to a Julia expression with `parse`

### Notes

For assignments, the nomenclature `:=` is also valid and here it is replaced
to `=`, but you need to set `assignment=true` for this replacement to take effect.

The characters `'('` and `')'` are deleted (replaced by the empty character),
whenever it is found that there are unbalanced parentheses after the expression is
split into subexpressions.
"""
function parse_sxmath(s; assignment=false)
    count_left_parentheses = s -> count(c -> c == '(', collect(s))
    count_right_parentheses = s -> count(c -> c == ')', collect(s))
    @assert count_left_parentheses(s) == count_right_parentheses(s) "the expression $(s) is not well formed"

    expr = strip.(split(replace(s, "&&" => "&"), "&"))
    if assignment
        expr = replace.(expr, Ref(":=" => "="))
    end
    expr = replace.(expr, Ref("==" => "="))

    # remove "true" statements
    filter!(expri -> expri != "true", expr)

    # remove irrelevant parentheses from the beginning and the end
    for (i, expri) in enumerate(expr)
        m = count_left_parentheses(expri)
        n = count_right_parentheses(expri)
        if m == n
            nothing
        elseif m > n && expri[1] == '('
            expr[i] = expri[2:end]
        elseif m < n && expri[end] == ')'
            expr[i] = expri[1:(end - 1)]
        else
            error("malformed subexpression $(expri)")
        end
    end
    return _parse_s.(expr)
end

"""
    parse_sxmodel!(root_sxmodel, HDict)

### Input

- `root_sxmodel` -- root element of an XML document
- `HDict`        -- dictionary that wraps the hybrid model and contains the keys
                    `(automaton, variables, transitionlabels, invariants, flows,
                    assignments, guards, switchings, nlocations, ntransitions)`

### Output

The `HDict` dictionary.

### Notes

1) Edge labels are not used and their symbol is (arbitrarily) set to the integer 1.
2) Location identifications ("id" field) are assumed to be integers.
3) The switchings types are assumed to be autonomous. See Switching in *Systems
   and Control*, D. Liberzon, for further details on the classification of switchings.
4) We add fresh variables for each component (`id_variable += 1`). In general
   variables can be shared among components if the bindings are defined. Currently,
   we make the simplifying assumption that the model has only one component and
   we don't take bindings into account.
"""
function parse_sxmodel!(root_sxmodel, HDict)

    # edge labels
    σ = 1

    # counter for the variables
    id_variable = 0

    # counter for the transitions
    id_transition = 0

    for component in eachelement(root_sxmodel)
        for field in eachelement(component)
            if nodename(field) == "param"
                if field["type"] == "real" || field["type"] == "bool"
                    id_variable += 1
                    add_variable!(HDict["variables"], field, id_variable)
                elseif field["type"] == "label"
                    add_transition_label!(HDict["transitionlabels"], field)
                else
                    error("param type $(field["type"]) unknown")
                end
            elseif nodename(field) == "location"
                (id_location, i, f) = parse_location(field)
                HDict["invariants"][id_location] = i
                HDict["flows"][id_location] = f
            elseif nodename(field) == "transition"
                id_transition += 1
                (q, r, guard, assignment) = parse_transition(field)
                add_transition!(HDict["automaton"], q, r, σ)
                HDict["switchings"][id_transition] = AutonomousSwitching()
                HDict["assignments"][id_transition] = assignment
                HDict["guards"][id_transition] = guard
            else
                error("node $(nodename(field)) unknown")
            end
        end
    end
    return HDict
end

"""
    add_variable!(variables, field, id=1)

### Input

- `variables` -- vector of symbolic variables
- `field`     -- an `EzXML.Node` node with containing information about a `param` field
- `id`        -- (optional, default: 1) integer that identifies the variable

### Output

The updated vector of symbolic variables.

### Notes

Parameters can be either variable names (type "real") or labels (type "label").
"""
function add_variable!(variables, field, id=1)
    @assert field["type"] == "real" || field["type"] == "bool"

    # d1 and d2 are the dimensions (d1=d2=1 for scalars)
    @assert field["d1"] == "1" && field["d2"] == "1"

    varname = _parse_s(field["name"])
    islocal = haskey(field, "local") ? _parse_s(field["local"]) : false
    iscontrolled = haskey(field, "controlled") ? _parse_s(field["controlled"]) : true
    dynamicstype = haskey(field, "dynamics") ? field["dynamics"] : "any"

    variables[varname] = Dict("local" => islocal,
                              "controlled" => iscontrolled,
                              "dynamics" => dynamicstype,
                              "id" => id)
    return variables
end

"""
    add_transition_label!(labels, field)

### Input

- `labels` -- vector of transition labels
- `field`  -- node with a `param` label field

### Output

The updated vector of transition labels.
"""
function add_transition_label!(labels, field)
    @assert field["type"] == "label"
    push!(labels, field["name"])
    return labels
end

"""
    parse_location(field)

### Input

- `field`  -- location node

### Output

The tuple `(id, invariant, flow)` where:

- `id` is the integer that identifies the location,
- `invariant` is the list of subexpressions that determine that invariant for this location,
-  `flow` is the list of ODEs that define the flow for this location.

Both the invariant and the flow are vectors of symbolic expressions `Expr`.
"""
function parse_location(field)
    id = _parse_t(Int, field["id"])

    # if it happens that no invariant (or no flow) is defined in the component,
    # then this function will return an empty list of expressions
    invariant, flow = Expr[:()], Expr[:()]
    for element in eachelement(field)
        if nodename(element) == "invariant"
            invariant = parse_sxmath(nodecontent(element))
        elseif nodename(element) == "flow"
            flow = parse_sxmath(nodecontent(element))
        elseif nodename(element) in ["note"]
            # ignore these
        else
            @warn("field $(nodename(element)) in location $(field["id"]) is ignored")
        end
    end
    return (id, invariant, flow)
end

"""
    parse_transition(field)

### Input

- `field`  -- transition node

### Output

The tuple `(q, r, G, A)` where `q` and `r` are the source mode and target mode
respectively for this transition, `G` is the list of guards for this transition,
and `A` is the list of assignments. `G` and `A` are vectors of
symbolic expressions `Expr`.

### Notes

It is assumed that the "source" and "target" fields can be cast to integers.

It can happen that the given transition does not contain the "guard" field (or
the "assignment", or both); in that case this function returns an empty of
expressions for those cases.
"""
function parse_transition(field)
    q, r = _parse_t(Int, field["source"]), _parse_t(Int, field["target"])
    G = Vector{Expr}()
    A = Vector{Expr}()
    for element in eachelement(field)
        if nodename(element) == "guard"
            G = parse_sxmath(nodecontent(element))
        elseif nodename(element) == "assignment"
            A = parse_sxmath(nodecontent(element); assignment=true)
        elseif nodename(element) in ["labelposition", "label", "middlepoint"]
            # ignore these
        else
            @warn("field $(nodename(element)) in transition $(field["source"]) → $(field["target"]) is ignored")
        end
    end
    return (q, r, G, A)
end
