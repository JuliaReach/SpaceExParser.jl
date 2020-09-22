using EzXML
@testset "Variables" begin
    X = parsexml("""
                 <param name="x" type="real" d1="1" d2="1" local="false" dynamics="any" controlled="true" />
                 """)
    vars = Dict()
    SpaceExParser.add_variable!(vars, root(X))
    @test collect(keys(vars)) == [:x]
    @test vars[:x]["local"] == false
    @test vars[:x]["controlled"] == true
    @test vars[:x]["dynamics"] == "any"
    @test vars[:x]["id"] == 1
end
