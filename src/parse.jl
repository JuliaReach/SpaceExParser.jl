"""
    parse_sxmath(s)

Returns the list of expressions corresponding to a given SX string.

### Input

- `s` - string

### Output

Vector of expressions, equations or inequalities.

### Examples

```jldoctest
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

Consists of the following steps:

- split the string with the `&` key
- remove trailing whitespace of each substring
- replace double `==` with single `=`
- cast to a Julia expression with `parse`
"""
parse_sxmath(s) = parse.(replace.(strip.(split(s, "&")), "==", "="))

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
    i = 0 # index of the current component

    # count the number of locations for each component
    for component in eachelement(root_sxmodel)
        if nodename(component) == "component"
            i += 1
            push!(lcount, 0)
            push!(tcount, 0)
            for field in eachelement(component)
                if nodename(field) == "location"
                    lcount[i] += 1
                elseif nodename(field) == "transition"
                    tcount[i] += 1
                end
            end
        end
    end
    return (lcount, tcount)
end

"""
    add_variable!(variables, field)

### Input

- `variables` -- vector of symbolic variables
- `field`     -- node with a `param` variable field

### Output

The updated vector of symbolic variables.

### Notes

Parameters can be either variable names (type "real") or labels (type "label").
"""
function add_variable!(variables, field)
    @assert field["type"] == "real"

    # d1 and d2 are the dimensions (d1=d2=1 for scalars)
    @assert field["d1"] == "1" && field["d2"] == "1"

    varname = parse(field["name"])
    islocal = haskey(field, "local") ? parse(field["local"]) : false
    iscontrolled = haskey(field, "controlled") ? parse(field["controlled"]) : true
    dynamicstype = haskey(field, "dynamics") ? field["dynamics"] : "any"
    variables[varname] = Dict("local"=>islocal,
                              "controlled"=>iscontrolled,
                              "dynamics"=>dynamicstype)
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

The tuple `(I, f)` where `I` is the list of invariants for this location,
and `f` is the list of ODEs that define the flow. Both objects are vectors of
symbolic expressions `Expr`.
"""
function parse_location(field)
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
    return (I, f)
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
"""
function parse_transition(field)
    q, r = Int(float(field["source"])), Int(float(field["target"]))

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

#=
"""
    add_location!(modes, variables, I, f)
"""
function add_location!(modes, variables, I, f)
    nothing
    # differentiate w.r.t. controlled variables
    # A = Matrix{Float64}



       A = rand(2, 2); B = rand(2, 2) # build these ones from the content
       U = nothing
       s = ConstrainedLinearControlContinuousSystem(A, B, X, U)
       i = Int(float(field["id"]))
       modes[i] = s
       return modes

       for ki in keys(variables)
    # for controlled variables, there is an ODE
    if variables[ki]["controlled"]
        println(ki)
    end
end
[variables[s]["controlled"] for s in keys(variables)]

end


"""
    add_transition!(automaton, resetmaps, switchings, G, A)
"""
function add_transition!(automaton, resetmaps, switchings, G, A)
    nothing
end

=#
