# Methods

This section describes systems methods implemented in `SX.jl`.

```@contents
Pages = ["methods.md"]
Depth = 3
```

```@meta
CurrentModule = SX
DocTestSetup = quote
    using SX
end
```

### Input/Output

```@docs
readsxmodel
linearHS
```

### Parsing the SX language

```@docs
SX.count_locations_and_transitions
SX.parse_sxmath
SX.parse_sxmodel!
SX.add_variable!
SX.add_transition_label!
SX.parse_location
SX.parse_transition
```

### Conversion of symbolic expressions into sets

```@docs
SX.is_halfspace
SX.is_hyperplane
SX.is_linearcombination
```
