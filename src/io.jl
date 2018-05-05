"""
    readsxmodel(file; raw_dict=false, ST=ConstrainedLinearControlContinuousSystem, N=Float64, kwargs...)

Read a SX model file.

### Input

- `file`      -- the filename of the SX file (in XML format)
- `raw_dict`  -- (optional, default: `false`) if `true`, return the raw dictionary with
                 the objects that define the model (see Output below), without
                 actually returning a `HybridSystem`; otherwise, instantiate a
                 `HybridSystem` with the given assumptions
- `ST`        -- (optional, default: `nothing`) assumption for the type of mathematical
                 system for each mode
- `N`         -- (optional, default: `Float64`) numeric type of the system's coefficients

### Output

Hybrid system that corresponds to the given SX model and the given assumptions
on the system type if `raw_dict=true`; otherwise, a dictionary with the Julia
expression objects that define the model. The keys of this dictionary are:

- `automaton`
- `variables`
- `transitionlabels`
- `invariants`
- `flows`
- `resetmaps`
- `switchings`

### Notes

This function makes the following assumptions:

1) The model contains only 1 component. If the model contains more than 1 component,
   an error is raised. In this case, recall that network components can be
   flattened using `sspaceex`.
2) Location identifications ("id" field) are integers.
4) The default and a custom `ST` parameter assume that all modes are of the same
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
6) The nature of the switchings is autonomous: if there are guards, these define
   state-dependent switchings only. Switching control functions are not yet implemented.

These comments apply whenever `raw_dict=false`:

1) The field `variables` is an ordered dictionary, where the order is given by the
   insertion order. This allows deterministic iteration over the dictionary,
   (notice that in a usual dictionary, the order in which the elements are returned
   does not correspond, in general, to the order in which the symbols were saved).
   The `variables` are stored in the coefficients matrix using this insertion order.
2) If `ST` is `nothing`, the modes are given as the vector of tuples `(flows, invariants)`,
   each component being a list of expressions.
"""
function readsxmodel(file; raw_dict=false,
                           ST=nothing,
                           N=Float64,
                           kwargs...)

    # 1) Open XML and read number of components and locations
    # =======================================================
    sxmodel = readxml(file)
    root_sxmodel = root(sxmodel)

    nlocations_in_components, ntransitions_in_components = count_locations_and_transitions(root_sxmodel)
    ncomponents = length(nlocations_in_components)
    if ncomponents > 1
        error("read $(ncomponents) components, but models with more than one component are not yet implemented; try flattening the model")
    elseif ncomponents < 1
        error("read $(ncomponents) components, but the model should have a positive number of components")
    end
    # keep the 1st component
    nlocations, ntransitions = nlocations_in_components[1], ntransitions_in_components[1]

    # 2) Parse SX model and make the dictionary of Julia expressions
    # ==============================================================

    # hybrid automaton with the given number of locations
    automaton = LightAutomaton(nlocations)

    # ditionary with variables names and their properties
    variables = DataStructures.OrderedDict{Symbol, Dict{String, Any}}()

    # set of labels for the transitions
    transitionlabels = Set{String}()

    # vector with the invariants for each location
    invariants = Vector{Vector{Expr}}(nlocations)

    # vector with the ODE flow for each location
    flows = Vector{Vector{Expr}}(nlocations)

    # assignments for each transition (equations)
    # guards for each transition (lists of inequalities)
    resetmaps = Vector{Vector{Expr}}(ntransitions)

    switchings = FillArrays.Fill(AutonomousSwitching(), ntransitions)

    HDict = Dict("automaton"=>automaton,
                 "variables"=>variables,
                 "transitionlabels"=>transitionlabels,
                 "invariants"=>invariants,
                 "flows"=>flows,
                 "resetmaps"=>resetmaps,
                 "switchings"=>switchings,
                 "nlocations"=>nlocations,
                 "ntransitions"=>ntransitions)

    parse_sxmodel!(root_sxmodel, HDict)

    if raw_dict
        return HDict
    elseif ST == nothing
        modes = [(flows[i], invariants[i]) for i in 1:nlocations]
        # extension field
        ext = Dict{Symbol, Any}(:variables=>variables,
                                :transitionlabels=>transitionlabels)
        return HybridSystem(automaton, modes, resetmaps, switchings, ext)
    end

    # 2) Use a custom system type and symbolic representations
    # =======================================================
    if ST == ConstrainedLinearControlContinuousSystem
        #(state_variables, input_variables, modes, resetmaps, switchings) = linearHS(HDict; N=N, kwargs...)
        error("`linearHS` with system type $(ST) is not yet implemented")
    else
        error("the system type $(ST) is not supported")
    end

    # extension field
    ext = Dict{Symbol, Any}(:state_variables=>state_variables,
                            :input_variables=>input_variables,
                            :transitionlabels=>transitionlabels)

    return HybridSystem(automaton, modes, resetmaps, switchings, ext)
end
