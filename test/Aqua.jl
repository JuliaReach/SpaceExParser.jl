using SpaceExParser, Test
import Aqua

@testset "Aqua tests" begin
    Aqua.test_all(SpaceExParser; ambiguities=false)

    # do not warn about ambiguities in dependencies
    Aqua.test_ambiguities(SpaceExParser)
end
