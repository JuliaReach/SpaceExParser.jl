# Drive train example
# ============================

using HybridSystems, MathematicalSystems, LazySets, Plots

AFFINE_SYSTEM = ConstrainedLinearControlContinuousSystem
HS = readsxmodel("examples/Drivetrain/drivetrain_theta1_5percent_flat_manually.xml", ST=AFFINE_SYSTEM)
# initial condition in mode 1
X0 = Hyperrectangle(low=[9.9, 0.0], high=[10.1, 0.0])

# calculate reachable states up to time T
prob = InitialValueProblem(HS, X0)
input_options = Options(:mode=>"reach")

problem_options = Options(:vars=>[1,2], :T=>10.0, :δ=>0.005, :plot_vars=>[1, 2], :verbosity=>1);
options_input = merge(problem_options, input_options)
using Polyhedra
sol = solve_hybrid(HS, X0, options_input);

plot(sol, indices=1:2:length(sol.Xk))
