# About

This page contains some general information about this project, and recommendations
about contributing.

```@contents
Pages = ["about.md"]
```

## Contributing

If you like this package, consider contributing!

[Creating an issue](https://help.github.com/en/articles/creating-an-issue) in the [GitHub issue tracker](https://github.com/JuliaReach/SpaceExParser.jl/issues) to report a bug, open a discussion about existing functionality, or suggesting new functionality is appreciated.

If you have written code and would like it to be peer reviewed and added to the library, you can [fork](https://help.github.com/en/articles/fork-a-repo) the repository and send a pull request (see below). Typical contributions include fixing a bug, adding a new feature or improving the documentation (either in source code or the [online manual](https://juliareach.github.io/SpaceExParser.jl/latest/man/getting_started/)).

You are also welcome to get in touch with us in the [JuliaReach gitter chat](https://gitter.im/JuliaReach/Lobby).

Below we detail some general comments about contributing to this package. The [JuliaReach Developer's Documentation](https://juliareach.github.io/JuliaReachDevDocs/latest/) describes coding guidelines; take a look when in doubt about the coding style that is expected for the code that is finally merged into the library.

### Branches

Each pull request (PR) should be pushed in a new branch with the name of the author
followed by a descriptive name, e.g. `mforets/my_feature`. If the branch is
associated to a previous discussion in one issue, we use the name of the issue for easier
lookup, e.g. `mforets/7`.

### Unit testing and continuous integration (CI)

This project is synchronized with GitHub Actions such that each PR gets tested
before merging (and the build is automatically triggered after each new commit).
For the maintainability of this project, it is important to make all unit tests
pass.

To run the unit tests locally, you can do:

```julia
julia> using Pkg

julia> Pkg.test("ReachabilityBase")
```

We also advise adding new unit tests when adding new features to ensure
long-term support of your contributions.

### Contributing to the documentation

This documentation is written in Markdown, and it relies on
[Documenter.jl](https://github.com/JuliaDocs/Documenter.jl) to produce the HTML
layout. To build the docs, run `make.jl`:

```bash
$ julia --color=yes docs/make.jl
```

## Credits

These persons have contributed to `SpaceExParser.jl` (in alphabetic order):

- [Marcelo Forets](http://mforets.github.io)
- Nikos Kekatos
- [Christian Schilling](https://www.christianschilling.net/)
