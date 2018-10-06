# Drive train example
# ============================

using HybridSystems, MathematicalSystems, LazySets, Plots
import SX:is_halfspace, is_hyperplane, convert, parse_sxmath


x1 = parse_sxmath("x1 - -0.0488 == 0.0005600000000000001 * (x4 - 20.0)")
x2 = parse_sxmath("x2 - -15.67 == 0.46699999999999997 * (x4 - 20.0)")
x3 = parse_sxmath("x3 == 0.0")
x4 = parse_sxmath("x4 <= 40.0")
x5 = parse_sxmath("x5 == 0.0")
x6 = parse_sxmath("x6 - 20.0 == 1.0 * (x4 - 20.0)")
x7 = parse_sxmath("x7 - 240.0 == 12.0 * (x4 - 20.0)")
x8 = parse_sxmath("x8 - -0.0019199999999999998 == 0.00005999999999999998 * (x4 - 20.0)")
x9 = parse_sxmath("x9 - 20.0 == 1.0 * (x4 - 20.0)")
t = parse_sxmath("t == 0.0")

expr_p = parse_sxmath("x1 - -0.0488 == 0.0005600000000000001 * (x4 - 20.0) & x2 - -15.67 == 0.46699999999999997 * (x4 - 20.0) & x3 == 0.0 & x5 == 0.0 & x6 - 20.0 == 1.0 * (x4 - 20.0) & x7 - 240.0 == 12.0 * (x4 - 20.0) & x8 - -0.0019199999999999998 == 0.00005999999999999998 * (x4 - 20.0) & x9 - 20.0 == 1.0 * (x4 - 20.0) & 20.0 <= x4 & x4 <= 40.0 & t == 0.0")
expr = [x1, x2, x3, x4,x5,x6,x7,x8,x9,t]
x0sets = []
vars = Basic[:x1, :x2, :x3, :x4, :x5, :x6, :x7, :x8, :x9, :t]
for expr_i in expr_p
    if is_halfspace(expr_i)
        push!(x0sets, convert(HalfSpace, expr_i, vars=vars))
    elseif is_hyperplane(expr_i)
        push!(x0sets, convert(Hyperplane, expr_i, vars=vars))
    end
end


AFFINE_SYSTEM = ConstrainedLinearControlContinuousSystem
HS = readsxmodel("examples/Drivetrain/drivetrain_theta1_5percent_flat_manually.xml", ST=AFFINE_SYSTEM)
# initial condition in mode 1

# calculate reachable states up to time T
prob = InitialValueProblem(HS, x0sets)
input_options = Options(:mode=>"reach")

problem_options = Options(:vars=>[1,3,10], :T=>10.0, :δ=>0.005, :plot_vars=>[1, 3], :verbosity=>1);
options_input = merge(problem_options, input_options)
using Polyhedra
sol = solve_hybrid(HS, X0, options_input);

plot(sol, indices=1:2:length(sol.Xk))
