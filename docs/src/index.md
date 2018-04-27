# SX.jl

```@meta
DocTestFilters = [r"[0-9\.]+ seconds \(.*\)"]
```

`SX` is a [Julia](http://julialang.org) package to read SpaceEx modeling files.


The SpaceEx modeling language (SX) is a format for the mathematical description
of hybrid dynamical systems. It has been described in
[The SpaceEx Modeling Language](http://spaceex.imag.fr/sites/default/files/spaceex_modeling_language_0.pdf),
Scott Cotton, Goran Frehse, Olivier Lebeltel. See also [An Introduction to SpaceEx](spaceex.imag.fr/sites/default/files/introduction_to_spaceex_0.pdf),
Goran Frehse, 2010.

A visual model editor is available for download in the [SpaceEx website](http://spaceex.imag.fr/download-6).
See the examples in this documentation for screenshots and further details.

The aim of this library is to read SX modeling files and transform them into Julia
objects, for their inspection and analysis, such as reachability computations.

## Features

- Parse SX files into types defined in Julia packages `HybridSystems.jl` and `Systems.jl`.
- Can read arbitrary ODEs, eg. non-linear dynamics in the ODE flow for each mode.

## Library Outline

```@contents
Pages = [
    "lib/types.md",
    "lib/methods.md"
]
Depth = 2
```
