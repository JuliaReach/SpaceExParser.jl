# SpaceExParser.jl

| **Documentation** | **Status** | **Community** | **License** |
|:-----------------:|:----------:|:-------------:|:-----------:|
| [![docs-dev][dev-img]][dev-url] | [![CI][ci-img]][ci-url] [![codecov][cov-img]][cov-url] [![aqua][aqua-img]][aqua-url] | [![zulip][chat-img]][chat-url] | [![license][lic-img]][lic-url] |

[dev-img]: https://img.shields.io/badge/docs-latest-blue.svg
[dev-url]: https://juliareach.github.io/SpaceExParser.jl/dev/
[ci-img]: https://github.com/JuliaReach/SpaceExParser.jl/workflows/CI/badge.svg
[ci-url]: https://github.com/JuliaReach/SpaceExParser.jl/actions/workflows/ci.yml
[cov-img]: https://codecov.io/github/JuliaReach/SpaceExParser.jl/coverage.svg
[cov-url]: https://app.codecov.io/github/JuliaReach/SpaceExParser.jl
[aqua-img]: https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg
[aqua-url]: https://github.com/JuliaTesting/Aqua.jl
[chat-img]: https://img.shields.io/badge/zulip-join_chat-brightgreen.svg
[chat-url]: https://julialang.zulipchat.com/#narrow/stream/278609-juliareach
[lic-img]: https://img.shields.io/github/license/mashape/apistatus.svg
[lic-url]: https://github.com/JuliaReach/SpaceExParser.jl/blob/master/LICENSE

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
