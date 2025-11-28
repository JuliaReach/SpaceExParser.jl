using Test, SpaceExParser, HybridSystems, MathematicalSystems

include("unit_parse.jl")
@static if VERSION < v"1.12.0" || VERSION > v"1.12.2"
    # Julia parser is broken for `'` in v1.12.0 - v1.12.2
    include("unit_examples.jl")
    include("unit_affine.jl")
end

include("Aqua.jl")
