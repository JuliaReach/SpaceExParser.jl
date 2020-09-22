__precompile__(true)

module SpaceExParser

#=========================================
Load dependencies
=========================================#

using DataStructures: OrderedDict
using EzXML, HybridSystems, LazySets, MathematicalSystems, Reexport, SymEngine

#=========================
Input/Output functions
==========================#
export readsxmodel
include("io.jl")

#=========================
Parsing SpaceExParser files
==========================#
include("parse.jl")

#================================================
Converting symbolic expressions and systems types
=================================================#
include("convert.jl")
include("symbolic.jl")

end # module
