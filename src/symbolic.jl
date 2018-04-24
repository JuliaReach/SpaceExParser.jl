# TODO add docstring, parse X, U, resetmaps, switchings
function to_symbolic(HDict, nlocations, ST, N, kwargs...)

   state_variables = Vector{Basic}()
   input_variables = Vector{Basic}()

   for vi in keys(HDict["variables"])
      if HDict["variables"][vi]["controlled"]
         push!(state_variables, convert(Basic, vi))
      else
         push!(input_variables, convert(Basic, vi))
      end
   end

   # vector of modes
   modes = Vector{ST}(nlocations)

   for id_location in 1:nlocations
       # dimension of the statespace for this location
       n = length(HDict["flows"][id_location])

       # dynamics matrix
       A = Matrix{N}(n, n)

       # forcing terms
       m = length(input_variables)
       B = Matrix{N}(n, m)

       # loop over each flow equation for this location
       for (i, fi) in enumerate(HDict["flows"][id_location])
           RHS = convert(Basic, fi.args[2])

           # constant terms FIXME
           constant_terms = subs(RHS, [vi=>zero(N) for vi in state_variables]...) # TODO: is it possible without using subs?

           # terms linear in the variables
           ex = diff.(RHS, state_variables)
           A[i, :] = convert.(N, ex)

       end
       X = nothing  # FIXME
       U = nothing  # FIXME
       modes[id_location] = ST(A, B, X, U)
   end

   resetmaps = HDict["resetmaps"] # FIXME
   switchings = HDict["switchings"] # FIXME

   return (state_variables, input_variables, modes, resetmaps, switchings)
end
