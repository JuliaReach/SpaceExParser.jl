__precompile__(true)

module SX

using EzXML, Reexport
@reexport using HybridSystems, Systems, SymEngine

#=========================
Input/Output functions
==========================#
export readsxmodel
include("io.jl")

#=========================
Parsing SX files
==========================#
# for internal use
include("parse.jl")

end # module
