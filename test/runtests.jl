using SX
using Base.Test

@testset "Bouncing ball" begin
    H = readsxmodel("../examples/bball/bball_flattened.xml")
    @test nmodes(H) == 1
    @test ntransitions(H) == 1

    flow, invariant = H.modes[1][1], H.modes[1][2]
    @test flow == [:(x' = v), :(v' = -1)]
    @test invariant == [:(x >= 0)]

    assignment, guard = H.resetmaps[1], H.switchings[1]
    @test assignment == [:(x' = x), :(v' = -0.75v)]
    @test guard == [:(x = 0), :(v < 0)]
end

@testset "Van der Pol" begin
    H = readsxmodel("../examples/van_der_pol_fourth_quadrant/van_der_pol_fourth_quadrant.xml")
    @test nmodes(H) == 1
    @test ntransitions(H) == 0

    flow, invariant = H.modes[1][1], H.modes[1][2]
    @test flow == [:(x' = y), :(y' = -x + (1 - x ^ 2) * y)]
    @test invariant == [:(x <= 0), :(y >= 0)]
end

@testset "Lotka-Volterra" begin
    H = readsxmodel("../examples/lotka_volterra_fourth_quadrant/lotka_volterra_fourth_quadrant.xml")
    @test nmodes(H) == 1
    @test ntransitions(H) == 0

    flow, invariant = H.modes[1][1], H.modes[1][2]
    @test flow == [:(x' = x * (1 - y)), :(y' = -((1 - x) * y))]
    @test invariant == [:(x >= 0), :(y >= 0)]
end

@testset "Circle" begin
    H = readsxmodel("../examples/circle/circle_flattened.xml")
    @test nmodes(H) == 2
    @test ntransitions(H) == 2
    for (i, ti) in enumerate(transitions(H))
        if i == 1
            @test source(H, ti) == 1 && target(H, ti) == 2
        elseif i == 2
            @test source(H, ti) == 2 && target(H, ti) == 1
        end
    end

    m = H.modes[1]
    flow, invariant = m[1], m[2]
    @test flow == [:(x' = -y), :(y' = x)] && invariant == [:(y >= 0)]
    m = H.modes[2]
    flow, invariant = m[1], m[2]
    @test flow == [:(x' = -y), :(y' = x)] && invariant == [:(y <= 0)]

    # guards
    @test H.switchings == [[:(y = 0)], [:(y >= 0)]]

    # assignments
    @test H.resetmaps == [[:(x' = x), :(y' = y)], [:(x' = x), :(y' = y)]]
end
