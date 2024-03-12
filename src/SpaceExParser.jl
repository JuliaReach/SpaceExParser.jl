__precompile__(true)

module SpaceExParser

#=========================================
Load dependencies
=========================================#

using HybridSystems, LazySets
using DataStructures: OrderedDict
import MathematicalSystems
using MathematicalSystems: AbstractSystem, AbstractContinuousSystem,
                           LinearContinuousSystem, LinearControlContinuousSystem,
                           AffineContinuousSystem,
                           AffineControlContinuousSystem,
                           ConstrainedLinearContinuousSystem,
                           ConstrainedLinearControlContinuousSystem,
                           ConstrainedLinearControlDiscreteSystem,
                           ConstrainedAffineContinuousSystem,
                           ConstrainedAffineControlContinuousSystem
using EzXML: readxml, root, eachelement, nodename, nodecontent
using SymEngine: Basic, subs
import Base: convert
import SymEngine: convert, free_symbols

#=========================
Input/Output functions
==========================#
export readsxmodel
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
export writesxmodel
include("write.jl")

end # module
