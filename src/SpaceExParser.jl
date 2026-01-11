module SpaceExParser

export readsxmodel, writesxmodel

#=========================================
Load dependencies
=========================================#

using DataStructures: OrderedDict
using EzXML: readxml, root, eachelement, nodename, nodecontent
using HybridSystems: AbstractSwitching, AutonomousSwitching, GraphAutomaton,
                     HybridSystem, add_transition!, assignment, guard, inputdim,
                     inputset, nmodes, ntransitions, resetmap, source, statedim,
                     stateset, target, transitions
using LazySets: LazySets, AbstractHyperrectangle, HalfSpace, Hyperplane,
                Intersection, LazySet, Singleton, dim, high, isuniversal, low
using MathematicalSystems: MathematicalSystems, AbstractSystem,
                           AbstractContinuousSystem, LinearContinuousSystem,
                           LinearControlContinuousSystem,
                           AffineContinuousSystem,
                           AffineControlContinuousSystem,
                           ConstrainedLinearContinuousSystem,
                           ConstrainedLinearControlContinuousSystem,
                           ConstrainedLinearControlDiscreteSystem,
                           ConstrainedAffineContinuousSystem,
                           ConstrainedAffineControlContinuousSystem
using SymEngine: Basic, free_symbols, subs

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
