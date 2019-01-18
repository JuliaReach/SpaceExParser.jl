__precompile__(true)

module SX

#========================================
Compatibility for previous Julia versions
==============-==========================#
include("compat.jl")

import DataStructures, FillArrays
using EzXML, Reexport
@reexport using HybridSystems, MathematicalSystems, SymEngine
using LazySets

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
