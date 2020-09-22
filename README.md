# SpaceExParser.jl

[![Build Status](https://travis-ci.org/JuliaReach/SpaceExParser.jl.svg?branch=master)](https://travis-ci.org/JuliaReach/SpaceExParser.jl)
[![Docs latest](https://img.shields.io/badge/docs-latest-blue.svg)](http://juliareach.github.io/SpaceExParser.jl/latest/)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)](https://github.com/JuliaReach/SpaceExParser.jl/blob/master/LICENSE.md)
[![Code coverage](http://codecov.io/github/JuliaReach/SpaceExParser.jl/coverage.svg?branch=master)](https://codecov.io/github/JuliaReach/SpaceExParser.jl?branch=master)
[![Join the chat at https://gitter.im/JuliaReach/Lobby](https://badges.gitter.im/JuliaReach/Lobby.svg)](https://gitter.im/JuliaReach/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

`SpaceExParser` is a [Julia](http://julialang.org) package to parse SpaceEx modeling files.

## Resources

- [Manual](http://juliareach.github.io/SpaceExParser.jl/latest/)
- [Contributing](https://juliareach.github.io/SpaceExParser.jl/latest/about/#Contributing-1)
- [Release notes](https://github.com/JuliaReach/SpaceExParser.jl/releases)
- [Release notes of the development version](https://github.com/JuliaReach/SpaceExParser.jl/wiki/Release-log-tracker)

## Installing

This package requires Julia v1.0 or later. Refer to the
[official documentation](https://julialang.org/downloads) on how to install and
run Julia in your system.

To install the package `SpaceExParser`, use the following command inside Julia's REPL:

```julia
using Pkg
Pkg.clone("https://github.com/JuliaReach/SpaceExParser.jl")
```

*Dependencies*. This package relies on the interfaces defined in [HybridSystems.jl](https://github.com/blegat/HybridSystems.jl) and [MathematicalSystems.jl](https://github.com/JuliaReach/MathematicalSystems.jl). To handle XML files, we use [EzXML.jl](https://github.com/bicycle1885/EzXML.jl). Symbolic algebraic manipulations are performed with [SymEngine](https://github.com/symengine/SymEngine.jl). 

## Usage

