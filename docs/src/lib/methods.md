# Methods

This section describes systems methods implemented in `SX.jl`.

```@contents
Pages = ["methods.md"]
Depth = 3
```

```@meta
CurrentModule = SX
```

### Input/Output

```@docs
readsxmodel
linearHS
```

### Parsing the SX language

```@docs
count_locations_and_transitions
parse_sxmath
parse_sxmodel!
add_variable!
add_transition_label!
parse_location
parse_transition
```

### Conversion of symbolic expressions into sets

```@docs
convert
free_symbols
is_halfspace
is_hyperplane
is_linearcombination
```
