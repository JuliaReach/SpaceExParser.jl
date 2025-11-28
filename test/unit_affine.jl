using LazySets
AFFINE_SYSTEM = ConstrainedLinearControlContinuousSystem

@testset "Bouncing ball" begin
    H = readsxmodel(joinpath(@__DIR__, "../examples/bball/bball_flattened.xml"); ST=AFFINE_SYSTEM)

    @test nmodes(H) == 1
    @test ntransitions(H) == 1

    # test variables names in the given order
    @test collect(keys(H.ext[:variables])) == [:x, :v]

    S = H.modes[1]
    @test S.A == [0.0 1.0; 0.0 0.0]
    @test S.B == reshape([0.0, -1.0], (2, 1))
    @test S.X[1] isa HalfSpace && S.X[1].a == [-1.0, 0.0] && S.X[1].b == 0.0 # -x <= 0 <=> x >= 0
    @test S.U[1] isa Singleton && S.U[1].element == [1.0]

    R = H.resetmaps[1]
    @test R.A == [1.0 0.0; 0.0 -0.75]
    @test isempty(R.B) && size(R.B) == (2, 0)
    @test length(R.X) == 2
    @test R.X[1] isa Hyperplane && R.X[1].a == [1.0, 0.0] && R.X[1].b == 0.0 # x = 0
    @test R.X[2] isa HalfSpace && R.X[2].a == [0.0, 1.0] && R.X[1].b == 0.0 # v < 0
end
