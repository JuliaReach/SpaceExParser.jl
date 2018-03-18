# SX.jl

```@meta
DocTestFilters = [r"[0-9\.]+ seconds \(.*\)"]
```

`SX` is a [Julia](http://julialang.org) package to parse SpaceEx modeling files.

## Features

- Parse SX files into types defined in Julia packages `HybridSystems.jl` and `Systems.jl`.

## Examples

The folder `/examples` contains a collection of model files that are available from different
sources:

- [SpaceEx webpage](http://spaceex.imag.fr/download-6), small selection of
  examples that is part of the VM Server distribution and can be executed directly
  from the SpaceEx web interface.

## Library Outline

```@contents
Pages = [
    "lib/types.md",
    "lib/methods.md"
]
Depth = 2
```
