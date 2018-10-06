# Drive train example
# ============================

using HybridSystems, MathematicalSystems, LazySets, Plots
import SX:is_halfspace, is_hyperplane, convert, parse_sxmath
import LazySets.HalfSpace

expr_p = parse_sxmath("0.2<=x & x<=0.3 & -0.1<=y & y<=0.1 & z==0 & x1==0 & x2==0 & x3==0")
#expr = [x,y,x1,x2,x3,z]
x0sets = []
vars = Basic[:x, :y, :x1, :x2, :x3, :z]
for expr_i in expr_p
    if is_halfspace(expr_i)
        push!(x0sets, convert(HalfSpace, expr_i, vars=vars))
    elseif is_hyperplane(expr_i)
        push!(x0sets, convert(Hyperplane, expr_i, vars=vars))
    end
end


AFFINE_SYSTEM = ConstrainedLinearControlContinuousSystem
HS = readsxmodel("examples/filtered_oscillator/filtered_oscillator_flattened.xml", ST=AFFINE_SYSTEM)
# initial condition in mode 1


# calculate reachable states up to time T
prob = InitialValueProblem(HS, x0sets)
input_options = Options(:mode=>"reach")

problem_options = Options(:vars=>[1,2], :T=>99.0, :δ=>0.01, :plot_vars=>[1, 2],
                          :max_jumps=>15, :verbosity=>1)
options_input = merge(problem_options, input_options)
using Polyhedra
sol = solve(prob, options_input);

plot(sol, indices=1:2:length(sol.Xk))
