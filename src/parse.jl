"""
    count_locations_and_transitions(root_sxmodel)

Returns the number of locations and transitions for each component.

### Input

- `root_sxmodel` -- the root element of a SX file

### Output

Two vectors of integers `(lcount, tcount)`, where the i-th entry of `lcount` and
`tcount` are number of locations and transitions, respectively, of the i-th component.
"""
function count_locations_and_transitions(root_sxmodel)
    lcount = Vector{Int}() # num locations for each component
    tcount = Vector{Int}() # num transitions for each component
    id_component = 0 # index of the current component

    # count the number of locations for each component
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
    parse_sxmath(s)

Returns the list of expressions corresponding to a given SX string.

### Input

- `s` - string

### Output

Vector of expressions, equations or inequalities.

### Examples

```jldoctest
julia> import SX.parse_sxmath

julia> parse_sxmath("x >= 0")
1-element Array{Expr,1}:
 :(x >= 0)

julia> parse_sxmath("x' == x & v' == -0.75*v")
2-element Array{Expr,1}:
 :(x' = x)
 :(v' = -0.75v)

julia> parse_sxmath("x == 0 & v <= 0")
2-element Array{Expr,1}:
 :(x = 0)
 :(v <= 0)
```

### Algorithm

Consists of the following steps (in the given order):

- split the string with the `&` key
- remove trailing whitespace of each substring
- replace double `==` with single `=`
- cast to a Julia expression with `parse`
"""
parse_sxmath(s) = parse.(replace.(strip.(split(s, "&")), "==", "="))

"""
    parse_sxmodel!(root_sxmodel, HDict)

### Input

- `HDict` - dictionary that wraps the hybrid model and contains the keys `(automaton,
            variables, transitionlabels, invariants, flows, resetmaps, switchings)`

### Output

The `HDict` dictionary.

### Notes

Edge labels are not used and their symbol is (arbitrarily) set to the integer 1.
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
                if field["type"] == "real"
                    id_variable += 1
                    add_variable!(HDict["variables"], field, id_variable)
                elseif field["type"] == "label"
                    add_transition_label!(HDict["transitionlabels"], field)
                else
                    error("param type unknown")
                end
            elseif nodename(field) == "location"
                (id_location, i, f) = parse_location(field)
                HDict["invariants"][id_location] = i
                HDict["flows"][id_location] = f
            elseif nodename(field) == "transition"
                id_transition += 1
                (q, r, guard, assignment) = parse_transition(field)
                add_transition!(HDict["automaton"], q, r, σ)
                HDict["switchings"][id_transition] = guard
                HDict["resetmaps"][id_transition] = assignment
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
- `field`     -- node with a `param` variable field
- `id`        -- (optional, default: 1) integer that identifies the variable

### Output

The updated vector of symbolic variables.

### Notes

Parameters can be either variable names (type "real") or labels (type "label").
"""
function add_variable!(variables, field, id=1)
    @assert field["type"] == "real"

    # d1 and d2 are the dimensions (d1=d2=1 for scalars)
    @assert field["d1"] == "1" && field["d2"] == "1"

    varname = parse(field["name"])
    islocal = haskey(field, "local") ? parse(field["local"]) : false
    iscontrolled = haskey(field, "controlled") ? parse(field["controlled"]) : true
    dynamicstype = haskey(field, "dynamics") ? field["dynamics"] : "any"

    variables[varname] = Dict("local"=>islocal,
                              "controlled"=>iscontrolled,
                              "dynamics"=>dynamicstype,
                              "id"=>id)
    return variables
end

"""
    add_transition_label!(labels, field)

### Input

- `labels` -- vector of transition labels
- `field`  -- node with a `param` label field

### Output

The updated vector of transition labels.

### Notes

Parameters can be either variable names (type "real") or labels (type "label").
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

The tuple `(id, I, f)` where `id` is the integer that identifies the location,
`I` is the list of invariants for this location, and `f` is the list of ODEs that
define the flow. Both objects are vectors of symbolic expressions `Expr`.
"""
function parse_location(field)
    id = parse(Int, field["id"])
    local I, f
    for element in eachelement(field)
        if nodename(element) == "invariant"
            I = parse_sxmath(nodecontent(element))
        elseif nodename(element) == "flow"
            f = parse_sxmath(nodecontent(element))
        else
            warn("field $(nodename(element)) in location $(field["id"]) is ignored")
        end
    end
    return (id, I, f)
end

"""
    parse_transition(field)

### Input

- `field`  -- transition node

### Output

The tuple `(q, r, G, A)` where `q` and `r` are the source mode and target mode
respectively for this location, `G` is the list of guards for this location,
and `A` is the list of assignments. Both objects are vectors of
symbolic expressions `Expr`.

### Notes

It is assumed that the "source" and "target" fields can be cast to integers.
"""
function parse_transition(field)
    q, r = parse(Int, field["source"]), parse(Int, field["target"])
    local G, A
    for element in eachelement(field)
        if nodename(element) == "guard"
            G = parse_sxmath(nodecontent(element))
        elseif nodename(element) == "assignment"
            A = parse_sxmath(nodecontent(element))
        else
            warn("field $(nodename(element)) in transition $(field["source"]) → $(field["target"]) is ignored")
        end
    end
    return (q, r, G, A)
end
