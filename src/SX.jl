__precompile__(true)

module SX

#=========================================
Load dependencies
=========================================#

using DataStructures: OrderedDict
using EzXML, HybridSystems, LazySets, MathematicalSystems, Reexport, SymEngine

#=========================================
Compatibility for previous Julia versions
=========================================#
include("compat.jl")

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
