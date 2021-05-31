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
    ind.ind = ind.ind * ind.step
end

function dedent!(ind::Indentation)
    ind.ind = ind.ind[1:end-(length(ind.step))]
end

function _write_indented(io, string, indentation)
    write(io, "$(indentation.ind)$string")
end

function _dedent(indentation)
    return 
end

function _variable_name(id, dictionary)
    get(dictionary, id, "x" * string(id))
end

function _input_name(id, dictionary)
    get(dictionary, id, "u" * string(id))
end

# ======================
# Creation of model file
# ======================

function writesxmodel(filename, system; dictionary=Dict())
    open(filename, "w") do io
        write(io,
"<?xml version=\"1.0\" encoding=\"iso-8859-1\"?>\n" * 
"<sspaceex xmlns=\"http://www-verimag.imag.fr/xml-namespaces/sspaceex\" version=\"0.2\" math=\"SpaceEx\">\n"
        )
        indentation = Indentation()
        indent!(indentation)
        _write_system(io, system, dictionary, indentation)
        dedent!(indentation)
        write(io, "</sspaceex>\n")
    end
    nothing
end

function _write_system(io, system::AbstractContinuousSystem, dictionary,
                       indentation)
    _write_component(io, system, dictionary, indentation)
end

function _write_component(io, system, dictionary, indentation)
    _write_indented(io, "<component id=\"system\">\n", indentation)
    indent!(indentation)
    _write_parameters(io, system, dictionary, indentation)
    _write_locations(io, system, dictionary, indentation)
    _write_transitions(io, system, dictionary, indentation)
    dedent!(indentation)
    _write_indented(io, "</component>\n", indentation)
end

function _write_parameters(io,
                           system::Union{LinearContinuousSystem,
                                         ConstrainedLinearContinuousSystem},
                           dictionary, indentation)
    _write_linear_system(io, system, dictionary, indentation)
end

function _write_parameters(io,
                           system::Union{LinearControlContinuousSystem,
                                         ConstrainedLinearControlContinuousSystem},
                           dictionary, indentation)
    _write_linear_system(io, system, dictionary, indentation)

    m = inputdim(system)
    controlled = false
    for i in 1:m
        name = _input_name(i, dictionary)
        _write_parameter(io, name, controlled, dictionary, indentation)
    end
end

function _write_linear_system(io, system::AbstractContinuousSystem,
                              dictionary, indentation)
    n = statedim(system)
    controlled = true
    for i in 1:n
        name = _variable_name(i, dictionary)
        _write_parameter(io, name, controlled, dictionary, indentation)
    end
end

function _write_parameter(io, name, controlled, dictionary, indentation)
    _write_indented(io, "<param name=\"$name\" type=\"real\" d1=\"1\" d2=\"1\" " *
        "local=\"false\" dynamics=\"any\" controlled=\"$controlled\" />\n",
        indentation)
end

function _write_locations(io, system::AbstractContinuousSystem, dictionary,
                          indentation)
    _write_location(io, system, 1, dictionary, indentation)
end

function _write_location(io, system, id, dictionary, indentation)
    name = "loc" * string(id)
    _write_indented(io, "<location id=\"$id\" name=\"$name\">\n", indentation)
    indent!(indentation)
    _write_invariant(io, system, dictionary, indentation)
    _write_flow(io, system, dictionary, indentation)
    dedent!(indentation)
    _write_indented(io, "</location>\n", indentation)
end

function _write_invariant(io, system, dictionary, indentation)
    if !isconstrained(system)
        # nothing to write
        return
    end

    _write_indented(io, "<invariant>", indentation)
    indent!(indentation)

    X = stateset(system)
    if X != nothing
        _write_invariant_states_specific(io, system, X, dictionary, indentation)
    end

    U = inputset(system)
    if U != nothing
        _write_invariant_inputs_specific(io, system, U, dictionary, indentation)
    end

    dedent!(indentation)
    write(io, "</invariant>\n")
end

function _write_invariant_states_specific(io, system, X, dictionary, indentation)
    println("WARNING: state constraints of type $(typeof(X)) are currenctly " *
        "not supported and will be ignored")
end

function _write_invariant_states_specific(io, system, X::Universe, dictionary,
                                          indentation)
    # nothing to write
end

function _write_invariant_states_specific(io, system, X::AbstractHyperrectangle,
                                          dictionary, indentation)
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

function _write_invariant_inputs_specific(io, system, U, dictionary, indentation)
    println("WARNING: input constraints of type $(typeof(U)) are currenctly " *
        "not supported and will be ignored")
end

function _write_invariant_inputs_specific(io, system, U::Universe, dictionary,
                                          indentation)
    # nothing to write
end

function _write_invariant_inputs_specific(io, system, U::AbstractHyperrectangle,
                                          dictionary, indentation)
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
    write(io, "</flow>\n")
end

function _write_flow_specific(io,
                              system::Union{LinearContinuousSystem,
                                            LinearControlContinuousSystem,
                                            ConstrainedLinearContinuousSystem,
                                            ConstrainedLinearControlContinuousSystem},
                              dictionary)
    A = state_matrix(system)
    n = statedim(system)

    B = input_matrix(system)  # returns `nothing` for systems with no inputs
    m = inputdim(system)

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
        if first
            # rhs was zero everywhere
            write(io, "0")
        end
        if i < n
            write(io, " &amp; ")
        end
    end
end

function _write_transitions(io, system::AbstractContinuousSystem, dictionary,
                            indentation)
    # nothing to write
end
