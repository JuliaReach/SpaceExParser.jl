"""
    readsxmodel(file; raw=false, ST=ConstrainedLinearControlContinuousSystem, kwargs...)

Read a SX model file.

### Input

- `file` -- the filename of the SX file (in XML format)
- `raw`  -- (optional, default: `false`) if `true`, return the raw expressions
            that define the model, without actually computing the `HybridSystem`;
            otherwise, instantiate a `HybridSystem` with the given assumptions
- `ST`   -- (optional, default: `ConstrainedLinearControlContinuousSystem`) assumption
            for the type of mathematical system for each mode

### Output

Hybrid system that corresponds to the given SX model if `raw=false`; otherwise,
a dictionary with the Julia expressio objects that define the model. The keys
of this dictionary are:

- `variables`
- `automaton`
- `invariants`
- `flows`
- ``

### Notes

Currently this function makes the following running assumptions:

1) The model contains only 1 component. If your model contains more than one
   component, recall that network components can be flattened using `sspaceex`.

Moreover:

1) The tags `<notes> ... <\notes>` are ignored.
2) The transition labels and symbolic variables are stored in the extension field
   (`ext`) of the output hybrid system.

### Algorithm

We use the location "id" field, an integer, such that each of the vectors `modes`,
`resetmaps` and `switchings` corresponds to the location with the given "id". For
example, `modes[1]` corresponds to the modes of the location with `id="1"`.
"""
function readsxmodel(file; ST=ConstrainedLinearControlContinuousSystem, kwargs...)

    # open XML
    sxmodel = readxml(file)
    root_sxmodel = root(sxmodel)

    lcount, tcount = count_locations_and_transitions(root_sxmodel)
    ncomponents = length(lcount)
    if ncomponents > 1
        error("read $(ncomponents) components, but models with more than one component are not yet implemented; try flattening the model")
    elseif ncomponents < 1
        error("read $(ncomponents) components, the model should have a positive number of components")
    end
    nlocations = lcount[1]
    ntransitions = tcount[1]

    # instantiate hybrid automaton with the given number of locations
    automaton = LightAutomaton(nlocations)

    # set of variables names (use Basic for SymEngine variables)
    # the order corresponds to the order in which they are read in the XML file
    #variables = Dict{Symbol, typeof(Dict{String, Any}())}()
    variables = Dict{Symbol, Any}()

    # set labels for the transitions
    transitionlabels = Set{String}()

    # (1) Parse the SX model
    # ======================

    # vector with the invariants for each location
    invariants = Vector{Vector{Expr}}(nlocations)

    # vector with the ODE flow for each location
    flows = Vector{Vector{Expr}}(nlocations)

    # assignments for each transition (equations)
    resetmaps = Vector{Vector{Expr}}(ntransitions)

    # guards for each transition (lists of inequalities)
    switchings = Vector{Vector{Expr}}(ntransitions)

    # edge label, it is set to be arbitrarily 1 for all edges
    σ = 1

    # outsource to:
    #parse_sxmodel!(root_sxmodel, automaton, variables, transitionlabels, invariants, flows, resetmaps, switchings)

    for component in eachelement(root_sxmodel)
        for field in eachelement(component)
            if nodename(field) == "param"
                if field["type"] == "real"
                    add_variable!(variables, field)
                elseif field["type"] == "label"
                    add_transition_label!(transitionlabels, field)
                else
                    error("param type unknown")
                end
            elseif nodename(field) == "location"
                (I, f) = parse_location(field)
                push!(invariants, I)
                push!(flows, f)
            elseif nodename(field) == "transition"
                (q, r, guard, assignment) = parse_transition(field)
                add_transition!(automaton, q, r, σ)
                push!(switchings, guard)
                push!(resetmaps, assignment)
            else
                error("node $(nodename(field)) unknown")
            end
        end
    end

    # (2) Return or create the Hybrid System with the given assumptions
    # =================================================================
    if raw
        return Dict("automaton"=>automaton,
                    "variables"=>variables,
                    "transitionlabels"=>transitionlabels,
                    )
    end

    # if the modes have invariants, they are defined as constraints (either state or
    # input constraints) of the system
    modes = Vector{ST}(nlocations)

    #add_location!(modes, variables, I, f)

    return HybridSystem(automaton, modes, resetmaps, switchings, variables)
end
