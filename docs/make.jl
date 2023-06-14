using Documenter, SpaceExParser

DocMeta.setdocmeta!(SpaceExParser, :DocTestSetup,
                    :(using SpaceExParser); recursive=true)

makedocs(; sitename="SpaceExParser.jl",
         modules=[SpaceExParser],
         format=Documenter.HTML(; prettyurls=get(ENV, "CI", nothing) == "true",
                                assets=["assets/aligned.css"]),
         strict=true,
         pages=["Home" => "index.md",
                "Examples" => Any["Introduction" => "examples/examples.md",
                                  "Bouncing ball" => "examples/bball.md"],
                "Library" => Any["Types" => "lib/types.md", "Methods" => "lib/methods.md"],
                "About" => "about.md"])

deploydocs(; repo="github.com/JuliaReach/SpaceExParser.jl.git",
           push_preview=true)
