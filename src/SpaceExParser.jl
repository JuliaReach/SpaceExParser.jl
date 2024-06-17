module SpaceExParser

export readsxmodel, writesxmodel

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

#=========================
Input/Output functions
==========================#
include("io.jl")

#====================
Parsing SpaceEx files
=====================#
include("parse.jl")

#===============================================
Converting symbolic expressions and system types
================================================#
include("symbolic.jl")

#==========================
Writing systems to new file
===========================#
include("write.jl")

end # module
