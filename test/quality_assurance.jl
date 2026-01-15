using SpaceExParser, Test
import Aqua, ExplicitImports

@testset "ExplicitImports tests" begin
    @test isnothing(ExplicitImports.check_all_explicit_imports_are_public(SpaceExParser))
    @test isnothing(ExplicitImports.check_all_explicit_imports_via_owners(SpaceExParser))
    ignores = (:_ishalfspace, :_ishyperplanar, :parse,)
    @test isnothing(ExplicitImports.check_all_qualified_accesses_are_public(SpaceExParser;
                                                                            ignore=ignores))
    @test isnothing(ExplicitImports.check_all_qualified_accesses_via_owners(SpaceExParser))
    @test isnothing(ExplicitImports.check_no_implicit_imports(SpaceExParser))
    @test isnothing(ExplicitImports.check_no_self_qualified_accesses(SpaceExParser))
    @test isnothing(ExplicitImports.check_no_stale_explicit_imports(SpaceExParser))
end

@testset "Aqua tests" begin
    Aqua.test_all(SpaceExParser)
end
