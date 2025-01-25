using Documenter, SpaceExParser, DocumenterCitations

DocMeta.setdocmeta!(SpaceExParser, :DocTestSetup,
                    :(using SpaceExParser); recursive=true)

bib = CitationBibliography(joinpath(@__DIR__, "src", "refs.bib"); style=:alpha)

makedocs(; sitename="SpaceExParser.jl",
         modules=[SpaceExParser],
         format=Documenter.HTML(; prettyurls=get(ENV, "CI", nothing) == "true",
                                assets=["assets/aligned.css", "assets/citations.css"]),
         pagesonly=true,
         plugins=[bib],
         pages=["Home" => "index.md",
                "Examples" => Any["Introduction" => "examples/examples.md",
                                  "Bouncing ball" => "examples/bball.md"],
                "Library" => Any["Types" => "lib/types.md", "Methods" => "lib/methods.md"],
                "Bibliography" => "bibliography.md",
                "About" => "about.md"])

deploydocs(; repo="github.com/JuliaReach/SpaceExParser.jl.git",
           push_preview=true)
