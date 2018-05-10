using LazySets

"""
linearHS(HDict; ST=ConstrainedLinearControlContinuousSystem,
                STD=ConstrainedLinearControlDiscreteSystem,
                N=Float64, kwargs...)

Convert the given hybrid system objects into a concrete system type for each node,
and Julia expressions into SymEngine symbolic expressions.

### Input

- `HDict` -- raw dictionary of hybrid system objects
- `ST`    -- (optional, default: `ConstrainedLinearControlContinuousSystem`)
             assumption for the type of mathematical system for each mode
- `STD`   -- (optional, default: `ConstrainedLinearControlDiscreteSystem`)
              assumption for the type of mathematical system for the assignments and guards
- `N`     -- (optional, default: `Float64`) numeric type of the system's coefficients

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
4) In inequalities, `x` is a vector of variables of two differens types only:
   either all of them are state variables, or all of them are input variables.
   Other combinations are not yet allowed.
5) Strict and non-strict inequalities are treated as being the same: both are
   mapped to half-spaces.
"""
function linearHS(HDict; ST=ConstrainedLinearControlContinuousSystem,
                         STD=ConstrainedLinearControlDiscreteSystem,
                         N=Float64, kwargs...)

    variables = HDict["variables"]
    invariants = HDict["invariants"]
    flows = HDict["flows"]
    assignments = HDict["assignments"]
    guards = HDict["guards"]
    state_variables = Vector{Basic}()
    input_variables = Vector{Basic}()

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
    modes = Vector{ST}(nlocations)

    # reset maps (assignments, guards) for each transition (equations)
    resetmaps = Vector{STD}(ntransitions)

    for id_location in eachindex(flows)

        # vector of input sets; can be bigger if there are constant inputs
        U = Vector{LazySet{N}}() # FIXME : use an intersection array?
        # should be a vector of vectors (one for each location)

        # vector of state constraints
        X = Vector{LazySet{N}}() # FIXME : use an intersection array?
        # should be a vector of vectors (one for each location)

        # dimension of the statespace for this location
        n = length(flows[id_location])

        # dynamics matrix
        A = Matrix{N}(n, n)

        # forcing terms
        B = Matrix{N}(n, m)
        C = zeros(N, n) # constant terms

        # track if there are constant terms
        isaffine = false

        # loop over each flow equation for this location
        for (i, fi) in enumerate(flows[id_location])

            # we are treating an equality x_i' = f(x, ...)
            @assert fi.head == :(=)

            # fi.args[1] is the subject of the equation, and fi.args[2] the right-hand side
            RHS = convert(Basic, fi.args[2])

            # constant terms (TODO: do we need to use subs?) use SymEngine.free_symbols ?
            const_term = subs(RHS, [xi=>zero(N) for xi in state_variables]..., [ui=>zero(N) for ui in input_variables]...)
            if const_term != zero(N)
                C[i] = const_term
                isaffine = true
            end
            # terms linear in the state variables
            ex = diff.(RHS, state_variables)
            A[i, :] = convert.(N, ex) # needs ex to be numeric, otherwise an error is prompted

            # terms linear in the input variables
            ex = diff.(RHS, input_variables)
            B[i, :] = convert.(N, ex) # needs ex to be numeric, otherwise an error is prompted
        end

        # convert invariants to set representations
        for (i, invi) = enumerate(invariants[id_location])
            if invi.head == :(=) # this is a hyperplane
                LHS = convert(Basic, invi.args[1])
                RHS = convert(Basic, invi.args[2].args[2])

                b = convert(N, RHS)
                # find if this is a state constraint or an input constraint
                if all(si in state_variables for si in free_symbols(LHS))
                    a = diff.(LHS, state_variables)
                    a = convert(Vector{N}, a)
                    push!(X, Hyperplane(a, b))
                elseif all(si in input_variables for si in free_symbols(LHS))
                    a = diff.(LHS, input_variables)
                    a = convert(Vector{N}, a)
                    push!(U, Hyperplane(a, b))
                else
                    error("the invariant $(invi) is not in the specified format")
                end

            elseif invi.head == :call && (invi.args[1] == :(>=) || invi.args[1] == :(>)) # this is a halfspace ax >= b
                LHS = convert(Basic, invi.args[2])
                RHS = convert(Basic, invi.args[3])

                b = convert(N, RHS)
                # find if this is a state constraint or an input constraint
                if all(si in state_variables for si in free_symbols(LHS))
                    a = diff.(LHS, state_variables)
                    a = convert(Vector{N}, a)
                    push!(X, HalfSpace(-a, -b))
                elseif all(si in input_variables for si in free_symbols(LHS))
                    a = diff.(LHS, input_variables)
                    a = convert(Vector{N}, a)
                    push!(U, HalfSpace(-a, -b))
                else
                    error("the invariant $(invi) is not in the specified format")
                end

            elseif invi.head == :call && (invi.args[1] == :(<=) || invi.args[1] == :(<)) # this is a halfspace ax <= b
                LHS = convert(Basic, invi.args[2])
                RHS = convert(Basic, invi.args[3])

                b = convert(N, RHS)
                # find if this is a state constraint or an input constraint
                if all(si in state_variables for si in free_symbols(LHS))
                    a = diff.(LHS, state_variables)
                    a = convert(Vector{N}, a)
                    push!(X, HalfSpace(a, b))
                elseif all(si in input_variables for si in free_symbols(LHS))
                    a = diff.(LHS, input_variables)
                    a = convert(Vector{N}, a)
                    push!(U, HalfSpace(a, b))
                else
                    error("the invariant $invi is not in the specified format")
                end
            else
                error("invariant $(invi) in location $id_location not understood")
            end
        end

        # if needed, concatenate the inputs with the constant terms
        if isaffine
            B = hcat(B, C)
            U = [Singleton([one(N)]) * Ui for Ui in U]
        end

        modes[id_location] = ST(A, B, X, U)
    end

    for id_location in eachindex(assignments)

        # input constraints for the reset maps
        Ur = Vector{LazySet{N}}() # FIXME : use an intersection array
        # should be a vector of vectors (one for each location)

        # state constraints for the reset maps
        Xr = Vector{LazySet{N}}() # FIXME : use an intersection array
        # should be a vector of vectors (one for each location)

        # dimension of the statespace for this location
        n = length(assignments[id_location])

        # dynamics matrix
        Ar = Matrix{N}(n, n)

        # forcing terms
        Br = Matrix{N}(n, m)
        Cr = zeros(N, n) # constant terms

        # track if there are constant terms
        isaffine = false

        # loop over each assignment equation for this location
        for (i, ai) in enumerate(assignments[id_location])

            # we are treating an equality x_i' = f(x, ...)
            @assert ai.head == :(=)

            # fi.args[1] is the subject of the equation, and fi.args[2] the right-hand side
            RHS = convert(Basic, ai.args[2])

            # constant terms (TODO: do we need to use subs?) use SymEngine.free_symbols ?
            const_term = subs(RHS, [xi=>zero(N) for xi in state_variables]..., [ui=>zero(N) for ui in input_variables]...)
            if const_term != zero(N)
                Cr[i] = const_term
                isaffine = true
            end
            # terms linear in the state variables
            ex = diff.(RHS, state_variables)
            Ar[i, :] = convert.(N, ex) # needs ex to be numeric, otherwise an error is prompted

            # terms linear in the input variables
            ex = diff.(RHS, input_variables)
            Br[i, :] = convert.(N, ex) # needs ex to be numeric, otherwise an error is prompted
        end

        # convert guards to set representations
        for (i, gi) = enumerate(guards[id_location])
            if gi.head == :(=) # this is a hyperplane
                LHS = convert(Basic, gi.args[1])
                expr = gi.args[2]
                if :args in fieldnames(expr)
                    RHS = convert(Basic, expr.args[2])
                else
                    RHS = convert(Basic, expr)
                end

                b = convert(N, RHS)
                # find if this is a state constraint or an input constraint
                if all(si in state_variables for si in free_symbols(LHS))
                    a = diff.(LHS, state_variables)
                    a = convert(Vector{N}, a)
                    push!(Xr, Hyperplane(a, b))
                elseif all(si in input_variables for si in free_symbols(LHS))
                    a = diff.(LHS, input_variables)
                    a = convert(Vector{N}, a)
                    push!(Ur, Hyperplane(a, b))
                else
                    error("the guard $(gi) is not in the specified format")
                end

            elseif gi.head == :call && (gi.args[1] == :(>=) || gi.args[1] == :(>)) # this is a halfspace ax >= b
                LHS = convert(Basic, gi.args[2])
                RHS = convert(Basic, gi.args[3])

                b = convert(N, RHS)
                # find if this is a state constraint or an input constraint
                if all(si in state_variables for si in free_symbols(LHS))
                    a = diff.(LHS, state_variables)
                    a = convert(Vector{N}, a)
                    push!(Xr, HalfSpace(-a, -b))
                elseif all(si in input_variables for si in free_symbols(LHS))
                    a = diff.(LHS, input_variables)
                    a = convert(Vector{N}, a)
                    push!(Ur, HalfSpace(-a, -b))
                else
                    error("the guard $(gi) is not in the specified format")
                end

            elseif gi.head == :call && (gi.args[1] == :(<=) || gi.args[1] == :(<)) # this is a halfspace ax <= b
                LHS = convert(Basic, gi.args[2])
                RHS = convert(Basic, gi.args[3])

                b = convert(N, RHS)
                # find if this is a state constraint or an input constraint
                if all(si in state_variables for si in free_symbols(LHS))
                    a = diff.(LHS, state_variables)
                    a = convert(Vector{N}, a)
                    push!(Xr, HalfSpace(a, b))
                elseif all(si in input_variables for si in free_symbols(LHS))
                    a = diff.(LHS, input_variables)
                    a = convert(Vector{N}, a)
                    push!(Ur, HalfSpace(a, b))
                else
                    error("the guard $gi is not in the specified format")
                end
            else
                error("guard $(gi) in location $id_location not understood")
            end
        end

        # if needed, concatenate the inputs with the constant terms
        if isaffine
            Br = hcat(Br, Cr)
            Ur = [Singleton([one(N)]) * Ui for Ui in Ur]
        end

        resetmaps[id_location] = STD(Ar, Br, Xr, Ur)
    end


    return (modes, resetmaps)
end
