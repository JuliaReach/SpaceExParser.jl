using Documenter, SX

makedocs(
    doctest = true,  # use this flag to skip doctests (saves time!)
    modules = [SX],
    format = :html,
    assets = ["assets/juliareach.css"],
    sitename = "SX.jl",
    pages = [
        "Home" => "index.md",
        "Examples" => "examples/examples.md",
        "Library" => Any[
        "Types" => "lib/types.md",
        "Methods" => "lib/methods.md"],
        "About" => "about.md"
    ]
)

deploydocs(
    repo = "github.com/JuliaReach/SX.jl.git",
    target = "build",
    osname = "linux",
    julia  = "0.6",
    deps = nothing,
    make = nothing
)
