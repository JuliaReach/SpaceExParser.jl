using Documenter, SpaceExParser, DocumenterCitations

DocMeta.setdocmeta!(SpaceExParser, :DocTestSetup,
                    :(using SpaceExParser); recursive=true)

bib = CitationBibliography(joinpath(@__DIR__, "src", "refs.bib"); style=:alpha)

# Julia parser is broken for `'` in v1.12.0 - v1.12.4
doctest = v"1.12.0" <= VERSION <= v"1.12.4" ? false : true

makedocs(; sitename="SpaceExParser.jl",
         modules=[SpaceExParser],
         format=Documenter.HTML(; prettyurls=get(ENV, "CI", nothing) == "true",
                                assets=["assets/aligned.css", "assets/citations.css"]),
         pagesonly=true,
         doctest=doctest,
         plugins=[bib],
         pages=["Home" => "index.md",
                "Examples" => Any["Introduction" => "examples/examples.md",
                                  "Bouncing ball" => "examples/bball.md"],
                "Library" => Any["Types" => "lib/types.md", "Methods" => "lib/methods.md"],
                "Bibliography" => "bibliography.md",
                "About" => "about.md"])

deploydocs(; repo="github.com/JuliaReach/SpaceExParser.jl.git",
           push_preview=true)
