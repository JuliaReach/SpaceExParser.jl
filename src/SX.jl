__precompile__(true)

module SX

import DataStructures, FillArrays
using EzXML, Reexport
@reexport using HybridSystems, MathematicalSystems, SymEngine

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
include("convert.jl")
include("symbolic.jl")

end # module
