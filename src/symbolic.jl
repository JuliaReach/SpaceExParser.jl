const NUM = Float64 # hard-coded numeric type for the expressions' coefficients

"""
    linearHS(HDict; ST=ConstrainedLinearControlContinuousSystem,
             STD=ConstrainedLinearControlDiscreteSystem,
             kwargs...)

Convert the given hybrid system objects into a concrete system type for each node,
and Julia expressions into SymEngine symbolic expressions.

### Input

- `HDict` -- raw dictionary of hybrid system objects
- `ST`    -- (optional, default: `ConstrainedLinearControlContinuousSystem`)
             assumption for the type of mathematical system for each mode
- `STD`   -- (optional, default: `ConstrainedLinearControlDiscreteSystem`)
              assumption for the type of mathematical system for the assignments and guards

### Output

The tuple `(modes, resetmaps)`.

### Notes

1) "Controlled" variables are interpreted as state variables (there is an ODE flow
    for them), otherwise these are interpreted as input variables (there is not an
    ODE for them).
2) If the system has nonlinearities, then some first order derivatives cannot
   be evaluated to numbers, and this function does not apply. In that case, you
   will see the error message: `ArgumentError: symbolic value cannot be
   evaluated to a numeric value`.
3) We assume that inequalities in invariants are of the form `ax <= b` or `ax >= b`,
   where `b` is a scalar value. Other combinations are NOT yet supported.
4) In inequalities, `x` is a vector of variables of two different types only:
   either all of them are state variables, or all of them are input variables.
   Other combinations are not yet allowed.
5) Strict and non-strict inequalities are treated as being the same: both are
   mapped to half-spaces.
"""
function linearHS(HDict; ST=ConstrainedLinearControlContinuousSystem,
                  STD=ConstrainedLinearControlDiscreteSystem,
                  kwargs...)
    variables = HDict["variables"]
    invariants = HDict["invariants"]
    flows = HDict["flows"]
    assignments = HDict["assignments"]
    guards = HDict["guards"]
    state_variables = Vector{Basic}()
    input_variables = Vector{Basic}()

    # in this point it is defined which variables are "state" and which are "input"
    for vi in keys(variables)
        if variables[vi]["controlled"]
            push!(state_variables, convert(Basic, vi))
        else
            push!(input_variables, convert(Basic, vi))
        end
    end
    m = length(input_variables)

    nlocations, ntransitions = HDict["nlocations"], HDict["ntransitions"]

    # vector of modes (flows, invariants)
    modes = Vector{ST}(undef, nlocations)

    for id_location in eachindex(flows)

        # vector of input sets; can be bigger if there are constant inputs
        U = Vector{LazySet{NUM}}() # FIXME : use an intersection array?
        # should be a vector of vectors (one for each location)

        # vector of state constraints
        X = Vector{LazySet{NUM}}() # FIXME : use an intersection array?
        # should be a vector of vectors (one for each location)

        # dimension of the state space for this location
        n = length(flows[id_location])

        # variables that are in the flow equations for this location
        local_state_variables = convert.(Basic, [fi.args[1].args[1] for fi in flows[id_location]])

        # in general local state variable are the same for all distinct
        # modes in a hybrid automaton. they may change if different hybrid models
        # are composed, so let's assume this here:
        @assert local_state_variables == state_variables

        # track if there are constant terms in this mode
        isaffine = false

        A, B, c = _get_coeffs(flows[id_location], n, m, state_variables, input_variables)
        isaffine = !iszero(c)

        # convert invariants to set representations
        _add_invariants!(X, U, invariants[id_location], state_variables, input_variables,
                         (Val(:location), id_location))

        # NOTE: simplification of the invariants in the current location can
        # take place here

        # if needed, concatenate the inputs with the constant terms
        if isaffine
            B = hcat(B, c)
            if !isempty(U)
                U = [Singleton([one(NUM)]) * Ui for Ui in U]
            else
                U = [Singleton([one(NUM)])]
            end
        end

        modes[id_location] = ST(A, B, X, U)
    end

    # reset maps (assignments, guards) for each transition (equations)
    resetmaps = Vector{STD}(undef, ntransitions)

    for (id_transition, assign) in enumerate(assignments)
        # input constraints for the reset maps
        Ur = Vector{LazySet{NUM}}() # FIXME : use an intersection array
        # should be a vector of vectors (one for each transition)

        # state constraints for the reset maps
        Xr = Vector{LazySet{NUM}}() # FIXME : use an intersection array
        # should be a vector of vectors (one for each transition)

        # dimension of the state space for this transition
        n = length(assign)

        # variables that are in the assignments equations for this location
        # FIXME : change local_state_variables name, does it need to match state_variables?
        local_state_variables = convert.(Basic, [ai.args[1].args[1] for ai in assign])

        # track if there are constant terms
        isaffine = false

        Ar, Br, cr = _get_coeffs(assign, n, m, local_state_variables, input_variables)
        isaffine = !iszero(cr)

        # convert guards to set representations
        _add_invariants!(Xr, Ur, guards[id_transition], local_state_variables, input_variables,
                         (Val(:transition), id_transition))

        # if needed, concatenate the inputs with the constant terms
        if isaffine
            Br = hcat(Br, cr)
            if !isempty(Ur)
                Ur = [Singleton([one(NUM)]) * Ui for Ui in Ur]
            else
                Ur = [Singleton([one(NUM)])]
            end
        end

        resetmaps[id_transition] = STD(Ar, Br, Xr, Ur)
    end

    return (modes, resetmaps)
end

# parse the coefficients for the system x' = Ax + Bu + c
function _get_coeffs(flow, n, m, state_variables, input_variables)
    A = Matrix{NUM}(undef, n, n)
    B = Matrix{NUM}(undef, n, m)
    c = zeros(NUM, n)

    # loop over each flow equation
    @inbounds for (i, fi) in enumerate(flow)
        # we expect an equation xi' = f(x1, ..., xi, ..., xn)
        @assert fi.head == :(=) "equality expected in flow or reset map, found $(fi.head)"

        # fi.args[1] is the subject of the equation, fi.args[2] is the right-hand side
        RHS = convert(Basic, fi.args[2])

        # constant term (if it exists)
        zeroed_state_terms = [xi => zero(NUM) for xi in state_variables]
        zeroed_input_terms = [ui => zero(NUM) for ui in input_variables]
        const_term = subs(RHS, zeroed_state_terms..., zeroed_input_terms...)
        if const_term != zero(NUM)
            c[i] = const_term
        end

        # terms linear in the *state* variables
        A[i, :] = convert.(NUM, diff.(RHS, state_variables))

        # terms linear in the *input* variables
        B[i, :] = convert.(NUM, diff.(RHS, input_variables))
    end
    return A, B, c
end

const STR_SET = "is neither a hyperplane nor a half-space, and conversion from this set is not implemented"
const STR_VAR = "contains a combination of state variables and input variables"

error_msg_set(::Val{:location}, i, l) = error("invariant $i in location $l " * STR_SET)
error_msg_var(::Val{:location}, i, l) = error("invariant $i in location $l " * STR_VAR)

error_msg_set(::Val{:transition}, g, t) = error("guard $g in transition $t " * STR_SET)
error_msg_var(::Val{:transition}, g, t) = error("guard $g in transition $t " * STR_VAR)

# ref_tuple is used for the error message
function _add_invariants!(X, U, invariants, state_variables, input_variables, ref_tuple)
    for (i, invi) in enumerate(invariants)
        if is_hyperplane(invi)
            set_type = Hyperplane{NUM}
        elseif is_halfspace(invi)
            set_type = HalfSpace{NUM}
        else
            inv_or_grd, loc_or_trans = ref_tuple
            error_msg_set(inv_or_grd, invi, loc_or_trans)
        end

        vars = free_symbols(invi, set_type)
        got_state_invariant = all(si in state_variables for si in vars)
        got_input_invariant = all(si in input_variables for si in vars)
        if got_state_invariant
            h = convert(set_type, invi; vars=state_variables)
            push!(X, h)
        elseif got_input_invariant
            h = convert(set_type, invi; vars=input_variables)
            push!(U, h)
        else
            # combination of state variables and input variables
            loc_or_trans, inv_or_grd = ref_tuple
            error_msg_var(loc_or_trans, invi, inv_or_grd)
        end
    end
end
