"""
    readsxmodel(file; [raw_dict]=false, [ST]=nothing, [kwargs]...)

Read a SpaceEx model file.

### Input

- `file`      -- the filename of the SpaceEx file (in XML format)
- `raw_dict`  -- (optional, default: `false`) if `true`, return the raw dictionary with
                 the objects that define the model (see Output below), without
                 actually returning a `HybridSystem`; otherwise, instantiate a
                 `HybridSystem` with the given assumptions
- `ST`        -- (optional, default: `nothing`) assumption for the type of
                 system for each mode

### Output

Hybrid system that corresponds to the given SpaceEx model and the given assumptions
on the system type if `raw_dict=true`; otherwise, a dictionary with the Julia
expression objects that define the model. The keys of this dictionary are:

- `automaton`
- `variables`
- `transitionlabels`
- `invariants`
- `flows`
- `assignments`
- `guards`
- `switchings`
- `nlocations`
- `ntransitions`

### Notes

Currently, this function makes the following assumptions:

1) The model contains only 1 component. If the model contains more than 1 component,
   an error is raised. In this case, recall that network components can be
   flattened using `sspaceex`.
2) The default and a custom `ST` parameter assume that all modes are of the same
   type. In general, you may pass a vector of system's types in `kwargs` (not implemented).

Moreover, let us note that:

1) The tags `<notes> ... <\notes>` are ignored.
2) Variable names are stored in the dictionary `variables`, together with other
   information such as if the variable is controlled or not. This dictionary is
   then stored in the extension field (`ext`) of the hybrid system.
3) The transition labels are stored in the extension field (`ext`) of the
   hybrid system.
4) We use the location "id" field (an integer), such that each of the vectors `modes`,
   `resetmaps` and `switchings` corresponds to the location with the given "id". For
   example, `modes[1]` corresponds to the mode for the location with `id="1"`.
5) The `name` field of a location is ignored.
6) The nature of the switchings is autonomous. If there are guards, these define
   state-dependent switchings only. Switching control functions are not yet implemented.
7) The `resetmaps` field consists of the vector of tuples `(assignment, guard)`, for each
   location.

These comments apply whenever `raw_dict=false`:

1) The field `variables` is an ordered dictionary, where the order is given by the
   insertion order. This allows deterministic iteration over the dictionary,
   (notice that in a usual dictionary, the order in which the elements are returned
   does not correspond, in general, to the order in which the symbols were saved).
   The `variables` are stored in the coefficients matrix using this insertion order.
2) If `ST` is `nothing`, the modes are given as the vector of tuples `(flows, invariants)`,
   each component being a list of expressions, and similarly the reset maps are
   the vector of tuples `(assignments, guards)`.
"""
function readsxmodel(file; raw_dict=false, ST=nothing, kwargs...)
    # 1) Open XML and read number of components and locations
    # =======================================================

    sxmodel = readxml(file)
    root_sxmodel = root(sxmodel)

    nlocations_vector, ntransitions_vector = count_locations_and_transitions(root_sxmodel)
    ncomponents = length(nlocations_vector)
    if ncomponents > 1
        error("read $(ncomponents) components, but models with more than one component are not yet implemented; try flattening the model")
    elseif ncomponents < 1
        error("read $(ncomponents) components, but the model should have a positive number of components")
    end
    # keep the 1st component
    nlocations, ntransitions = nlocations_vector[1], ntransitions_vector[1]

    # 2) Parse SpaceEx model and create a dictionary of Julia expressions
    # ===================================================================

    # hybrid automaton with the given number of locations
    automaton = GraphAutomaton(nlocations)

    # dictionary with variables names and their properties
    variables = OrderedDict{Symbol,Dict{String,Any}}()

    # set of labels for the transitions
    transitionlabels = Set{String}()

    # vector with the invariants for each location
    invariants = Vector{Vector{Expr}}(undef, nlocations)

    # vector with the ODE flow for each location
    flows = Vector{Vector{Expr}}(undef, nlocations)

    # assignments for each transition
    assignments = Vector{Vector{Expr}}(undef, ntransitions)

    # guards for each transition; subsets of state space where the state needs
    # to be to make the transition
    guards = Vector{Vector{Expr}}(undef, ntransitions)

    switchings = Vector{AbstractSwitching}(undef, ntransitions)

    HDict = Dict("automaton" => automaton,
                 "variables" => variables,
                 "transitionlabels" => transitionlabels,
                 "invariants" => invariants,
                 "flows" => flows,
                 "assignments" => assignments,
                 "guards" => guards,
                 "switchings" => switchings,
                 "nlocations" => nlocations,
                 "ntransitions" => ntransitions)

    parse_sxmodel!(root_sxmodel, HDict)

    if raw_dict
        return HDict
    end

    if isnothing(ST)
        modes = Vector{Tuple{Vector{Expr},Vector{Expr}}}()
        for i in eachindex(flows)
            push!(modes, (flows[i], invariants[i]))
        end

        resetmaps = Vector{Tuple{Vector{Expr},Vector{Expr}}}()
        for i in eachindex(assignments)
            push!(resetmaps, (assignments[i], guards[i]))
        end
    elseif ST == ConstrainedLinearControlContinuousSystem
        # Use a custom system type and symbolic representations
        (modes, resetmaps) = linearHS(HDict; kwargs...)
    else
        error("the system type $(ST) is not supported")
    end

    # extension field
    ext = Dict{Symbol,Any}()
    ext[:variables] = variables
    ext[:transitionlabels] = transitionlabels

    return HybridSystem(automaton, modes, resetmaps, switchings, ext)
end
