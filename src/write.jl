# ===========
# Indentation
# ===========

mutable struct Indentation
    ind::String
    step::String

    # default indentation: two spaces
    function Indentation(ind="", step="  ")
        return new(ind, step)
    end
end

function indent!(ind::Indentation)
    return ind.ind = ind.ind * ind.step
end

function dedent!(ind::Indentation)
    return ind.ind = ind.ind[1:(end - (length(ind.step)))]
end

function _write_indented(io, string, indentation)
    return write(io, "$(indentation.ind)$string")
end

# ==============
# Variable names
# ==============

function _variable_name(id, dictionary)
    return get(dictionary, id, "x" * string(id))
end

function _input_name(id, dictionary)
    return get(dictionary, id, "u" * string(id))
end

# ======================
# Creation of model file
# ======================

function writesxmodel(filename, system; dictionary=Dict())
    open(filename, "w") do io
        write(io,
              "<?xml version=\"1.0\" encoding=\"iso-8859-1\"?>\n" *
              "<sspaceex xmlns=\"http://www-verimag.imag.fr/xml-namespaces/sspaceex\" version=\"0.2\" math=\"SpaceEx\">\n")
        indentation = Indentation()
        indent!(indentation)
        _write_system(io, system, dictionary, indentation)
        dedent!(indentation)
        return write(io, "</sspaceex>\n")
    end
    return nothing
end

function _write_system(io, system, dictionary, indentation)
    return _write_component(io, system, dictionary, indentation)
end

function _write_component(io, system, dictionary, indentation)
    _write_indented(io, "<component id=\"system\">\n", indentation)
    indent!(indentation)
    _write_parameters(io, system, dictionary, indentation)
    _write_locations(io, system, dictionary, indentation)
    _write_transitions(io, system, dictionary, indentation)
    dedent!(indentation)
    return _write_indented(io, "</component>\n", indentation)
end

function _write_parameters(io, system, dictionary, indentation)
    _write_state_variables(io, system, dictionary, indentation)
    return _write_input_variables(io, system, dictionary, indentation)
end

function _write_input_variables(io, system, dictionary, indentation)
    m = inputdim(system)
    controlled = false
    for i in 1:m
        name = _input_name(i, dictionary)
        _write_parameter(io, name, controlled, indentation)
    end
end

function _write_state_variables(io, system, dictionary, indentation)
    n = statedim(system)
    controlled = true
    for i in 1:n
        name = _variable_name(i, dictionary)
        _write_parameter(io, name, controlled, indentation)
    end
end

function _write_parameter(io, name, controlled, indentation)
    return _write_indented(io,
                           "<param name=\"$name\" type=\"real\" d1=\"1\" d2=\"1\" " *
                           "local=\"false\" dynamics=\"any\" controlled=\"$controlled\" />\n",
                           indentation)
end

function _write_locations(io, system::AbstractContinuousSystem, dictionary,
                          indentation)
    return _write_location(io, system, 1, dictionary, indentation)
end

function _write_locations(io, system::HybridSystem, dictionary,
                          indentation)
    for (i, loc) in enumerate(system.modes)
        _write_location(io, loc, i, dictionary, indentation)
    end
end

function _write_location(io, system, id, dictionary, indentation)
    name = "loc" * string(id)
    _write_indented(io, "<location id=\"$id\" name=\"$name\">\n", indentation)
    indent!(indentation)
    _write_invariant(io, system, dictionary, indentation)
    _write_flow(io, system, dictionary, indentation)
    dedent!(indentation)
    return _write_indented(io, "</location>\n", indentation)
end

function _write_invariant(io, system, dictionary, indentation)
    if !isconstrained(system)
        return  # nothing to write
    end

    wrote_prefix = false

    X = stateset(system)
    if !isnothing(X) && !isuniversal(X)
        if !wrote_prefix
            _write_invariant_prefix(io, indentation)
            wrote_prefix = true
        end
        _write_state_constraints_specific(io, system, X, dictionary, indentation)
    end

    U = inputset(system)
    if !isnothing(U) && !isuniversal(U)
        if !wrote_prefix
            _write_invariant_prefix(io, indentation)
            wrote_prefix = true
        end
        _write_input_constraints_specific(io, system, U, dictionary, indentation)
    end

    if wrote_prefix
        _write_invariant_suffix(io, indentation)
    end
end

function _write_invariant_prefix(io, indentation)
    _write_indented(io, "<invariant>", indentation)
    return indent!(indentation)
end

function _write_invariant_suffix(io, indentation)
    dedent!(indentation)
    return write(io, "</invariant>\n")
end

function _write_state_constraints_specific(::IO, ::AbstractSystem, X, ::Dict,
                                           ::Indentation)
    return println("WARNING: state constraints of type $(typeof(X)) are currently " *
                   "not supported and will be ignored")
end

function _write_state_constraints_specific(io::IO, ::AbstractSystem, X::AbstractHyperrectangle,
                                           dictionary::Dict, ::Indentation)
    for i in 1:dim(X)
        xi = _variable_name(i, dictionary)
        l = low(X, i)
        u = high(X, i)
        if i > 1
            write(io, " &amp; ")
        end
        write(io, "$l &lt;= $xi &amp; $xi &lt;= $u")
    end
end

function _write_state_constraints_specific(io::IO, ::AbstractSystem,
                                           H::Union{HalfSpace,Hyperplane},
                                           dictionary::Dict, ::Indentation)
    first = true
    for (i, ai) in enumerate(H.a)
        if ai == 0
            continue
        end
        xi = _variable_name(i, dictionary)
        if ai < 0
            if first
                prefix = "-"
            else
                prefix = " - "
            end
        else
            if first
                prefix = ""
            else
                prefix = " + "
            end
        end
        write(io, "$prefix$(abs(ai)) * $xi")
        first = false
    end
    if first
        # a = 0
        write(io, "0")
    end
    if H isa HalfSpace
        operator = "&lt;="
    elseif H isa Hyperplane
        operator = "=="
    else
        error("unsupported set type $(typeof(H))")
    end
    b = H.b
    if b == 0
        b = 0  # turns -0.0 into 0 (for aesthetic reasons only)
    end
    return write(io, " $operator $b")
end

function _write_state_constraints_specific(io::IO, system::Dict, X::Intersection,
                                           dictionary::Dict, indentation::Indentation)
    first = true
    for Xi in X
        if first
            first = false
        else
            write(io, " &amp; ")
        end
        _write_state_constraints_specific(io, system, Xi, dictionary, indentation)
    end
end

function _write_input_constraints_specific(::IO, system, U, dictionary, indentation)
    return println("WARNING: input constraints of type $(typeof(U)) are currently " *
                   "not supported and will be ignored")
end

function _write_input_constraints_specific(io::IO, ::AbstractSystem, U::AbstractHyperrectangle,
                                           dictionary, ::Indentation)
    for i in 1:dim(U)
        ui = _input_name(i, dictionary)
        l = low(U, i)
        u = high(U, i)
        if i > 1
            write(io, " &amp; ")
        end
        write(io, "$l &lt;= $ui &amp; $ui &lt;= $u")
    end
end

function _write_flow(io, system, dictionary, indentation)
    _write_indented(io, "<flow>", indentation)
    _write_flow_specific(io, system, dictionary)
    return write(io, "</flow>\n")
end

function _write_flow_specific(io,
                              system::Union{LinearContinuousSystem,
                                            LinearControlContinuousSystem,
                                            ConstrainedLinearContinuousSystem,
                                            ConstrainedLinearControlContinuousSystem,
                                            AffineContinuousSystem,
                                            AffineControlContinuousSystem,
                                            ConstrainedAffineContinuousSystem,
                                            ConstrainedAffineControlContinuousSystem},
                              dictionary)
    A = state_matrix(system)
    n = statedim(system)

    B = input_matrix(system)  # returns `nothing` for systems with no inputs
    m = inputdim(system)

    c = affine_term(system)
    if isnothing(c)
        c = zeros(eltype(A), n)
    end

    for i in 1:n
        xi = _variable_name(i, dictionary)
        write(io, "$xi' == ")
        first = true
        for j in 1:n
            Aij = A[i, j]
            if Aij == 0
                continue
            end
            xj = _variable_name(j, dictionary)
            if Aij < 0
                if first
                    prefix = "-"
                else
                    prefix = " - "
                end
            else
                if first
                    prefix = ""
                else
                    prefix = " + "
                end
            end
            write(io, "$prefix$(abs(Aij)) * $xj")
            first = false
        end
        for j in 1:m
            Bij = B[i, j]
            if Bij == 0
                continue
            end
            uj = _input_name(j, dictionary)
            if Bij < 0
                if first
                    prefix = "-"
                else
                    prefix = " - "
                end
            else
                if first
                    prefix = ""
                else
                    prefix = " + "
                end
            end
            write(io, "$prefix$(abs(Bij)) * $uj")
            first = false
        end
        if c[i] != 0
            if c[i] < 0
                if first
                    prefix = "-"
                else
                    prefix = " - "
                end
            else
                if first
                    prefix = ""
                else
                    prefix = " + "
                end
            end
            write(io, "$prefix$(abs(c[i]))")
            first = false
        end
        if first
            # rhs was zero everywhere
            write(io, "0")
        end
        if i < n
            write(io, " &amp; ")
        end
    end
end

function _write_transitions(::IO, system::AbstractContinuousSystem, dictionary,
                            indentation)
    # nothing to write
end

function _write_transitions(io, system::HybridSystem, dictionary, indentation)
    for transition in transitions(system)
        _write_transition(io, system, transition, dictionary, indentation)
    end
end

function _write_transition(io, H::HybridSystem, transition, dictionary, indentation)
    s = string(source(H, transition))
    t = string(target(H, transition))
    _write_indented(io, "<transition source=\"$s\" target=\"$t\">\n", indentation)
    indent!(indentation)
    _write_transition_label(io, H, transition, dictionary, indentation)
    _write_guard(io, H, transition, dictionary, indentation)
    _write_assignment(io, H, transition, dictionary, indentation)
    dedent!(indentation)
    return _write_indented(io, "</transition>\n", indentation)
end

function _write_transition_label(args...)
    # labels are ignored
end

function _write_guard(io, H, transition, dictionary, indentation)
    G = guard(H, transition)
    if isuniversal(G)
        return  # nothing to write
    end
    _write_indented(io, "<guard>", indentation)
    _write_state_constraints_specific(io, system, G, dictionary, indentation)
    return write(io, "</guard>\n")
end

function _write_assignment(io, H, transition, dictionary, indentation)
    asgn = resetmap(H, transition)  # workaround because transitions are parsed as system and not as map
    if isnothing(asgn)
        return  # nothing to write
    end

    n = _statedim(H)
    if asgn isa AbstractMap
        if (asgn isa IdentityMap) || (asgn isa ConstrainedIdentityMap)
            return  # nothing to write
        elseif (asgn isa MathematicalSystems.LinearMap) || (asgn isa ConstrainedLinearMap)
            A = asgn.A
            c = zeros(n)
        elseif (asgn isa MathematicalSystems.AffineMap) || (asgn isa ConstrainedAffineMap)
            A = asgn.A
            c = asgn.c
        elseif (asgn isa MathematicalSystems.ResetMap) || (asgn isa ConstrainedResetMap)
            A = zeros(n, n)
            c = zeros(n)
            @inbounds for i in 1:n
                if i in keys(asgn.dict)
                    c[i] = asgn.dict[i]
                else
                    A[i, i] = 1.0
                end
            end
        else
            @warn("only linear assignments are supported at the moment")
        end
    else
        A = state_matrix(asgn)
        if !iszero(input_matrix(asgn))
            @warn("only linear assignments are supported at the moment")
        end
    end

    _write_indented(io, "<assignment>", indentation)
    for i in 1:n
        xi = _variable_name(i, dictionary)
        write(io, "$xi' == ")
        first = true
        for j in 1:n
            Aij = A[i, j]
            if Aij == 0
                continue
            end
            xj = _variable_name(j, dictionary)
            if Aij < 0
                if first
                    prefix = "-"
                else
                    prefix = " - "
                end
            else
                if first
                    prefix = ""
                else
                    prefix = " + "
                end
            end
            write(io, "$prefix$(abs(Aij)) * $xj")
            first = false
        end
        if c[i] != 0
            if c[i] < 0
                if first
                    prefix = "-"
                else
                    prefix = " - "
                end
            else
                if first
                    prefix = ""
                else
                    prefix = " + "
                end
            end
            write(io, "$prefix$(abs(c[i]))")
            first = false
        end
        if first
            # rhs was zero everywhere
            write(io, "0")
        end
        if i < n
            write(io, " &amp; ")
        end
    end
    return write(io, "</assignment>\n")
end

function _statedim(H::HybridSystem)
    ns = [statedim(H, i) for i in 1:nmodes(H)]
    if !all(==(ns[1]), ns)
        @warn("the number of state dimensions differs across locations")
    end
    return maximum(ns)
end
