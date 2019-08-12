using Documenter, SX

DocMeta.setdocmeta!(SX, :DocTestSetup, :(using SX); recursive=true)

makedocs(
    sitename = "SX.jl",
    modules = [SX],
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        assets = ["assets/juliareach.css"]),
    pages = [
        "Home" => "index.md",
        "Examples" => Any["Introduction" => "examples/examples.md", "Bouncing ball" => "examples/bball.md"],
        "Library" => Any["Types" => "lib/types.md", "Methods" => "lib/methods.md"],
        "About" => "about.md"
    ],
    strict = true
)

deploydocs(
    repo = "github.com/JuliaReach/SX.jl.git"
)
