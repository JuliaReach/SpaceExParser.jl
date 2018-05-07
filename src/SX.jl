__precompile__(true)

module SX

import DataStructures, FillArrays
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
include("parse.jl")

#================================================
Converting symbolic expressions and systems types
=================================================#
include("symbolic.jl")

end # module
