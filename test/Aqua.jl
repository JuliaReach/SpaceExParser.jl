using SpaceExParser, Test
import Aqua

@testset "Aqua tests" begin
    Aqua.test_all(SpaceExParser; ambiguities=false,
                  # the piracies should be resolved in the future
                  piracies=(broken=true,))

    # do not warn about ambiguities in dependencies
    Aqua.test_ambiguities(SpaceExParser)
end
