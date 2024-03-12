__precompile__(true)

module SpaceExParser

export readsxmodel, writesxmodel

#=========================================
Load dependencies
=========================================#

using DataStructures: OrderedDict
using EzXML, HybridSystems, LazySets, MathematicalSystems, SymEngine

#=========================
Input/Output functions
==========================#
include("io.jl")

#====================
Parsing SpaceEx files
=====================#
include("parse.jl")

#================================================
Converting symbolic expressions and systems types
=================================================#
include("convert.jl")
include("symbolic.jl")

#==========================
Writing systems to new file
===========================#
include("write.jl")

end # module
