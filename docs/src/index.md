# SX.jl

```@meta
DocTestFilters = [r"[0-9\.]+ seconds \(.*\)"]
```

`SX` is a [Julia](http://julialang.org) package to parse SpaceEx modeling files.

## Features

- Parse SX files into types defined in Julia packages `HybridSystems.jl` and `Systems.jl`.

## Examples

The folder `/examples` contains a collection of model files that are available from different
sources:

- [SpaceEx webpage](http://spaceex.imag.fr/download-6), small selection of
  examples that is part of the VM Server distribution and can be executed directly
  from the SpaceEx web interface.

### Remarks

The examples consist of single hybrid automata that are constructed via flattening (parallel composition). This can be done via SpaceEx executable file with the command ``spaceex -g name.cfg -m name.xml --output-system-file new_name.xml``

However, note that the flattening process change the original model and may induce parsing errors. The parsing errors only appear when the constructed model is visualized/analyzed with the Model Editor or/and the Web Interface. There are no parsing errors with the source code/executable SpaceEx. A list of identified parsing problems follows below. 

		1. Special symbols, e.g. ~, _ in the variable and location names
		2. Characters and symbols in the notes
		3. Nondeterministic flows, e.g. x'==x+w, where 0<w1<0.1 (see bball_nondet)
		4. Nondeterministic resets, e.g. v' == -0.75*v+w2 (see bball_nondet)
		5. Naming issues, e.g. default variable name is component.subcomponent.variable

The aforementioned problems would yield errors/warnings when parsed.

```@contents
1. ERROR | in component 'osc_w_4th_order' the string 'osc.osci.hop'  
doesn't match NAME pattern [a-zA-Z_][a-zA-Z0-9_]* >>> element 
label removed 

2. Error: name="pp-always-always-always-always" value doesn't match 
NAME pattern [a-zA-Z_][a-zA-Z0-9_]*>>> set to default: "unnamed"

3. ERROR |  new LOCATION with name= 'unnamed'; name already exist,
renamed in 'unnamed2'

4. ERROR: Failed to parse model file phpxbMjAb.xml.
caused by: Could not parse base component system.
caused by: Failed to parse flow of location always.
caused by: Could not parse predicate

5. Constructed Reset: x' == x & v' == -0.75*v with offset 
support_function ( w1 >= -0.0499999 & w1 <= 0.0499999 & 
w2 >= -0.0999999 & w2 <= 0.0999999, mapped by x' == 0 & v' == w2 )

6. Constructed Flow:  x' == v & v' == -0.999999 with offset 
support_function(x >= 0 & SLACK2 <= 0.0999999 & SLACK2 >= 0 & 
SLACK4 <= 0.199999 & SLACK4 >= 0, mapped by x' == 0 & v' == -SLACK2+0.0499999 ) 
```


## Library Outline

```@contents
Pages = [
    "lib/types.md",
    "lib/methods.md"
]
Depth = 2
```
