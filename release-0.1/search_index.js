var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#SX.jl-1",
    "page": "Home",
    "title": "SX.jl",
    "category": "section",
    "text": "DocTestFilters = [r\"[0-9\\.]+ seconds \\(.*\\)\"]SX is a Julia package to read SpaceEx modeling files.The SpaceEx modeling language (SX) is a format for the mathematical description of hybrid dynamical systems. It has been described in The SpaceEx Modeling Language, Scott Cotton, Goran Frehse, Olivier Lebeltel. See also An Introduction to SpaceEx, Goran Frehse, 2010.A visual model editor is available for download on the SpaceEx website. See the examples in this documentation for screenshots and further details.The aim of this library is to read SX modeling files and transform them into Julia objects, for their inspection and analysis, such as reachability computations."
},

{
    "location": "index.html#Features-1",
    "page": "Home",
    "title": "Features",
    "category": "section",
    "text": "Parse SX files into types defined in Julia packages HybridSystems.jl and MathematicalSystems.jl.\nCan read arbitrary ODEs, eg. non-linear dynamics in the ODE flow for each mode."
},

{
    "location": "index.html#Library-Outline-1",
    "page": "Home",
    "title": "Library Outline",
    "category": "section",
    "text": "Pages = [\n    \"lib/types.md\",\n    \"lib/methods.md\"\n]\nDepth = 2"
},

{
    "location": "examples/examples.html#",
    "page": "Introduction",
    "title": "Introduction",
    "category": "page",
    "text": ""
},

{
    "location": "examples/examples.html#Introduction-1",
    "page": "Introduction",
    "title": "Introduction",
    "category": "section",
    "text": "Pages = [\"examples.md\"]\nDepth = 3The folder /examples contains a collection of model files that are available from different sources:SpaceEx webpage, small selection of examples that is part of the VM Server distribution and can be executed directly from the SpaceEx web interface."
},

{
    "location": "examples/examples.html#Remarks-1",
    "page": "Introduction",
    "title": "Remarks",
    "category": "section",
    "text": "The examples consist of single hybrid automata that are constructed via flattening (parallel composition). This can be done via SpaceEx executable file with the commandspaceex -g name.cfg -m name.xml --output-system-file new_name.xmlHowever, note that the flattening process changes the original model and may induce parsing errors. The parsing errors only appear when the constructed model is visualized/analyzed with the Model Editor or/and the Web Interface. There are no parsing errors with the source code/executable SpaceEx. A list of identified parsing problems follows below.Special symbols, e.g. ~, _ in the variable and location names\nSpecial characters, e.g. Greek or Russian letters\nNondeterministic flows, e.g. x\'==x+w1, where 0<w1<0.1 (see bball_nondet)\nNondeterministic resets, e.g. v\' == -0.75*v+w2 (see bball_nondet)\nNaming issues, e.g. default variable name is component.subcomponent.variableThe aforementioned problems would yield errors/warnings when parsed.1. ERROR | in component \'osc_w_4th_order\' the string \'osc.osci.hop\'  \ndoesn\'t match NAME pattern [a-zA-Z_][a-zA-Z0-9_]* >>> element\nlabel removed\n\n2. Error: name=\"pp-always-always-always-always\" value doesn\'t match\nNAME pattern [a-zA-Z_][a-zA-Z0-9_]*>>> set to default: \"unnamed\"\n\n3. ERROR |  new LOCATION with name= \'unnamed\'; name already exist,\nrenamed in \'unnamed2\'\n\n4. ERROR: Failed to parse model file phpxbMjAb.xml.\ncaused by: Could not parse base component system.\ncaused by: Failed to parse flow of location always.\ncaused by: Could not parse predicate\n\n5. Constructed Reset: x\' == x & v\' == -0.75*v with offset\nsupport_function ( w1 >= -0.0499999 & w1 <= 0.0499999 &\nw2 >= -0.0999999 & w2 <= 0.0999999, mapped by x\' == 0 & v\' == w2 )\n\n6. Constructed Flow:  x\' == v & v\' == -0.999999 with offset\nsupport_function(x >= 0 & SLACK2 <= 0.0999999 & SLACK2 >= 0 &\nSLACK4 <= 0.199999 & SLACK4 >= 0, mapped by x\' == 0 & v\' == -SLACK2+0.0499999 )"
},

{
    "location": "examples/bball.html#",
    "page": "Bouncing ball",
    "title": "Bouncing ball",
    "category": "page",
    "text": ""
},

{
    "location": "examples/bball.html#Bouncing-ball-1",
    "page": "Bouncing ball",
    "title": "Bouncing ball",
    "category": "section",
    "text": "Pages = [\"bball.md\"]\nDepth = 3(Image: Bouncing ball model)"
},

{
    "location": "lib/types.html#",
    "page": "Types",
    "title": "Types",
    "category": "page",
    "text": ""
},

{
    "location": "lib/types.html#Types-1",
    "page": "Types",
    "title": "Types",
    "category": "section",
    "text": "This section describes systems types implemented in SX.jl.Pages = [\"types.md\"]\nDepth = 3CurrentModule = SX\nDocTestSetup = quote\n    using SX\nend"
},

{
    "location": "lib/methods.html#",
    "page": "Methods",
    "title": "Methods",
    "category": "page",
    "text": ""
},

{
    "location": "lib/methods.html#Methods-1",
    "page": "Methods",
    "title": "Methods",
    "category": "section",
    "text": "This section describes systems methods implemented in SX.jl.Pages = [\"methods.md\"]\nDepth = 3CurrentModule = SX\nDocTestSetup = quote\n    using SX\nend"
},

{
    "location": "lib/methods.html#SX.readsxmodel",
    "page": "Methods",
    "title": "SX.readsxmodel",
    "category": "function",
    "text": "readsxmodel(file; raw_dict=false, ST=ConstrainedLinearControlContinuousSystem, N=Float64, kwargs...)\n\nRead a SX model file.\n\nInput\n\nfile      – the filename of the SX file (in XML format)\nraw_dict  – (optional, default: false) if true, return the raw dictionary with                the objects that define the model (see Output below), without                actually returning a HybridSystem; otherwise, instantiate a                HybridSystem with the given assumptions\nST        – (optional, default: nothing) assumption for the type of mathematical                system for each mode\nN         – (optional, default: Float64) numeric type of the system\'s coefficients\n\nOutput\n\nHybrid system that corresponds to the given SX model and the given assumptions on the system type if raw_dict=true; otherwise, a dictionary with the Julia expression objects that define the model. The keys of this dictionary are:\n\nautomaton\nvariables\ntransitionlabels\ninvariants\nflows\nassignments\nguards\nswitchings\nnlocations\nntransitions\n\nNotes\n\nCurrently, this function makes the following assumptions:\n\nThe model contains only 1 component. If the model contains more than 1 component, an error is raised. In this case, recall that network components can be flattened using sspaceex.\nThe default and a custom ST parameter assume that all modes are of the same type. In general, you may pass a vector of system\'s types in kwargs (not implemented).\n\nMoreover, let us note that:\n\nThe tags `<notes> ... <\n\notes>` are ignored.\n\nVariable names are stored in the dictionary variables, together with other information such as if the variable is controlled or not. This dictionary is then stored in the extension field (ext) of the hybrid system.\nThe transition labels are stored in the extension field (ext) of the hybrid system.\nWe use the location \"id\" field (an integer), such that each of the vectors modes, resetmaps and switchings corresponds to the location with the given \"id\". For example, modes[1] corresponds to the mode for the location with id=\"1\".\nThe name field of a location is ignored.\nThe nature of the switchings is autonomous. If there are guards, these define state-dependent switchings only. Switching control functions are not yet implemented.\nThe resetmaps field consists of the vector of tuples (assignment, guard), for each location.\n\nThese comments apply whenever raw_dict=false:\n\nThe field variables is an ordered dictionary, where the order is given by the insertion order. This allows deterministic iteration over the dictionary, (notice that in a usual dictionary, the order in which the elements are returned does not correspond, in general, to the order in which the symbols were saved). The variables are stored in the coefficients matrix using this insertion order.\nIf ST is nothing, the modes are given as the vector of tuples (flows, invariants), each component being a list of expressions, and similarly the reset maps are the vector of tuples (assignments, guards).\n\n\n\n"
},

{
    "location": "lib/methods.html#SX.linearHS",
    "page": "Methods",
    "title": "SX.linearHS",
    "category": "function",
    "text": "linearHS(HDict; ST=ConstrainedLinearControlContinuousSystem,                 STD=ConstrainedLinearControlDiscreteSystem,                 N=Float64, kwargs...)\n\nConvert the given hybrid system objects into a concrete system type for each node, and Julia expressions into SymEngine symbolic expressions.\n\nInput\n\nHDict – raw dictionary of hybrid system objects\nST    – (optional, default: ConstrainedLinearControlContinuousSystem)            assumption for the type of mathematical system for each mode\nSTD   – (optional, default: ConstrainedLinearControlDiscreteSystem)             assumption for the type of mathematical system for the assignments and guards\nN     – (optional, default: Float64) numeric type of the system\'s coefficients\n\nOutput\n\nThe tuple (modes, resetmaps).\n\nNotes\n\n\"Controlled\" variables are interpreted as state variables (there is an ODE flow  for them), otherwise these are interpreted as input variables (there is not an  ODE for them).\nIf the system has nonlinearities, then some first order derivatives cannot be evaluated to numbers, and this function does not apply. In that case, you will see the error message: ArgumentError: symbolic value cannot be evaluated to a numeric value.\nWe assume that inequalities in invariants are of the form ax <= b or ax >= b, where b is a scalar value. Other combinations are NOT yet supported.\nIn inequalities, x is a vector of variables of two differens types only: either all of them are state variables, or all of them are input variables. Other combinations are not yet allowed.\nStrict and non-strict inequalities are treated as being the same: both are mapped to half-spaces.\n\n\n\n"
},

{
    "location": "lib/methods.html#Input/Output-1",
    "page": "Methods",
    "title": "Input/Output",
    "category": "section",
    "text": "readsxmodel\nlinearHS"
},

{
    "location": "lib/methods.html#SX.count_locations_and_transitions",
    "page": "Methods",
    "title": "SX.count_locations_and_transitions",
    "category": "function",
    "text": "count_locations_and_transitions(root_sxmodel)\n\nReturns the number of locations and transitions for each component.\n\nInput\n\nroot_sxmodel – the root element of a SX file\n\nOutput\n\nTwo vectors of integers (lcount, tcount), where the i-th entry of lcount and tcount are the number of locations and transitions, respectively, of the i-th component.\n\n\n\n"
},

{
    "location": "lib/methods.html#SX.parse_sxmath",
    "page": "Methods",
    "title": "SX.parse_sxmath",
    "category": "function",
    "text": "parse_sxmath(s; assignment=false)\n\nReturns the list of expressions corresponding to a given SX string.\n\nInput\n\ns          – string\nassignment – (optional, default: false)\n\nOutput\n\nVector of expressions, equations or inequalities.\n\nExamples\n\njulia> import SX.parse_sxmath\n\njulia> parse_sxmath(\"x >= 0\")\n1-element Array{Expr,1}:\n :(x >= 0)\n\njulia> parse_sxmath(\"x\' == x & v\' == -0.75*v\")\n2-element Array{Expr,1}:\n :(x\' = x)\n :(v\' = -0.75v)\n\njulia> parse_sxmath(\"x == 0 & v <= 0\")\n2-element Array{Expr,1}:\n :(x = 0)\n :(v <= 0)\n\nParentheses are ignored:\n\njulia> parse_sxmath(\"(x == 0) & (v <= 0)\")\n2-element Array{Expr,1}:\n :(x = 0)\n :(v <= 0)\n\nSplitting is also performend over double ampersand symbols:\n\njulia> parse_sxmath(\"x == 0 && v <= 0\")\n2-element Array{Expr,1}:\n :(x = 0)\n :(v <= 0)\n\nIf you want to parse an assignment, use the assignment flag:\n\njulia> parse_sxmath(\"x := -x*0.1\", assignment=true)\n1-element Array{Expr,1}:\n :(x = -x * 0.1)\n\nCheck that we can parse expressions involving parentheses:\n\njulia> parse_sxmath(\"(t <= 125 & y>= -100)\")\n2-element Array{Expr,1}:\n :(t <= 125)\n :(y >= -100)\njulia> parse_sxmath(\"t <= 125 & (y>= -100)\")\n2-element Array{Expr,1}:\n :(t <= 125)\n :(y >= -100)\n\nAlgorithm\n\nFirst a sanity check (assertion) is made that the expression makes a coherent use of parentheses.\n\nThen, the following steps are done (in the given order):\n\nsplit the string with the & key, or &&\nremove trailing whitespace of each substring\nreplace double == with single =\ndetect unbalanced parentheses (beginning and final subexpressions) and in that case delete them\ncast to a Julia expression with parse\n\nNotes\n\nFor assignments, the nomenclature := is also valid and here it is replaced to =, but you need to set assignment=true for this replacement to take effect.\n\nThe characters \'(\' and \')\' are deleted (replaced by the empty character), whenever it is found that there are unbalanced parentheses after the expression is splitted into subexpressions.\n\n\n\n"
},

{
    "location": "lib/methods.html#SX.parse_sxmodel!",
    "page": "Methods",
    "title": "SX.parse_sxmodel!",
    "category": "function",
    "text": "parse_sxmodel!(root_sxmodel, HDict)\n\nInput\n\nroot_sxmodel – root element of an XML document\nHDict        – dictionary that wraps the hybrid model and contains the keys                   (automaton, variables, transitionlabels, invariants, flows,                   assignments, guards, switchings, nlocations, ntransitions)\n\nOutput\n\nThe HDict dictionary.\n\nNotes\n\nEdge labels are not used and their symbol is (arbitrarily) set to the integer 1.\nLocation identifications (\"id\" field) are assumed to be integers.\nThe switchings types are assumed to be autonomous. See Switching in Systems and Control, D. Liberzon, for further details on the classification of switchings.\nWe add fresh varaibles for each component (id_variable += 1). In general variables can be shared among components if the bindings are defined. Currently, we make the simplifying assumption that the model has only one component and we don\'t take bindings into account.\n\n\n\n"
},

{
    "location": "lib/methods.html#SX.add_variable!",
    "page": "Methods",
    "title": "SX.add_variable!",
    "category": "function",
    "text": "add_variable!(variables, field, id=1)\n\nInput\n\nvariables – vector of symbolic variables\nfield     – an EzXML.Node node with containing information about a param field\nid        – (optional, default: 1) integer that identifies the variable\n\nOutput\n\nThe updated vector of symbolic variables.\n\nNotes\n\nParameters can be either variable names (type \"real\") or labels (type \"label\").\n\n\n\n"
},

{
    "location": "lib/methods.html#SX.add_transition_label!",
    "page": "Methods",
    "title": "SX.add_transition_label!",
    "category": "function",
    "text": "add_transition_label!(labels, field)\n\nInput\n\nlabels – vector of transition labels\nfield  – node with a param label field\n\nOutput\n\nThe updated vector of transition labels.\n\n\n\n"
},

{
    "location": "lib/methods.html#SX.parse_location",
    "page": "Methods",
    "title": "SX.parse_location",
    "category": "function",
    "text": "parse_location(field)\n\nInput\n\nfield  – location node\n\nOutput\n\nThe tuple (id, I, f) where id is the integer that identifies the location, I is the list of subexpressions that determine that invariant for this location, and similarly f is the list of ODEs that define the flow for this location. Both objects are vectors of symbolic expressions Expr.\n\n\n\n"
},

{
    "location": "lib/methods.html#SX.parse_transition",
    "page": "Methods",
    "title": "SX.parse_transition",
    "category": "function",
    "text": "parse_transition(field)\n\nInput\n\nfield  – transition node\n\nOutput\n\nThe tuple (q, r, G, A) where q and r are the source mode and target mode respectively for this transition, G is the list of guards for this transition, and A is the list of assignments. G and A are vectors of symbolic expressions Expr.\n\nNotes\n\nIt is assumed that the \"source\" and \"target\" fields can be cast to integers.\n\nIt can happen that the given transition does not contain the \"guard\" field (or the \"assignment\", or both); in that case this function returns an empty of expressions for those cases.\n\n\n\n"
},

{
    "location": "lib/methods.html#Parsing-the-SX-language-1",
    "page": "Methods",
    "title": "Parsing the SX language",
    "category": "section",
    "text": "SX.count_locations_and_transitions\nSX.parse_sxmath\nSX.parse_sxmodel!\nSX.add_variable!\nSX.add_transition_label!\nSX.parse_location\nSX.parse_transition"
},

{
    "location": "lib/methods.html#SX.is_halfspace",
    "page": "Methods",
    "title": "SX.is_halfspace",
    "category": "function",
    "text": "is_halfspace(expr::Expr)\n\nReturn wheter the given expression corresponds to a halfspace.\n\nInput\n\nexpr – a symbolic expression\n\nOutput\n\ntrue if expr corresponds to a halfspace or false otherwise.\n\nExamples\n\njulia> import SX.is_halfspace\n\njulia> all(is_halfspace.([:(x1 <= 0), :(x1 < 0), :(x1 > 0), :(x1 >= 0)]))\ntrue\n\njulia> is_halfspace(:(2*x1 <= 4))\ntrue\n\njulia> is_halfspace(:(6.1 <= 5.3*f - 0.1*g))\ntrue\n\njulia> is_halfspace(:(2*x1^2 <= 4))\nfalse\n\njulia> is_halfspace(:(x1^2 > 4*x2 - x3))\nfalse\n\njulia> is_halfspace(:(x1 > 4*x2 - x3))\ntrue\n\n\n\n"
},

{
    "location": "lib/methods.html#SX.is_hyperplane",
    "page": "Methods",
    "title": "SX.is_hyperplane",
    "category": "function",
    "text": "is_hyperplane(expr::Expr)\n\nReturn wheter the given expression corresponds to a hyperplane.\n\nInput\n\nexpr – a symbolic expression\n\nOutput\n\ntrue if expr corresponds to a halfspace or false otherwise.\n\nExamples\n\njulia> import SX.is_hyperplane\n\njulia> is_hyperplane(:(x1 = 0))\ntrue\n\njulia> is_hyperplane(:(2*x1 = 4))\ntrue\n\njulia> is_hyperplane(:(6.1 = 5.3*f - 0.1*g))\ntrue\n\njulia> is_hyperplane(:(2*x1^2 = 4))\nfalse\n\njulia> is_hyperplane(:(x1^2 = 4*x2 - x3))\nfalse\n\njulia> is_hyperplane(:(x1 = 4*x2 - x3))\ntrue\n\n\n\n"
},

{
    "location": "lib/methods.html#SX.is_linearcombination",
    "page": "Methods",
    "title": "SX.is_linearcombination",
    "category": "function",
    "text": "is_linearcombination(L::Basic)\n\nReturn whether the expression L is a linear combination of its symbols.\n\nInput\n\nL – expression\n\nOutput\n\ntrue if L is a linear combination or false otherwise.\n\nExamples\n\njulia> import SX.is_linearcombination\n\njulia> is_linearcombination(:(2*x1 - 4))\ntrue\n\njulia> is_linearcombination(:(6.1 - 5.3*f - 0.1*g))\ntrue\n\njulia> is_linearcombination(:(2*x1^2))\nfalse\n\njulia> is_linearcombination(:(x1^2 - 4*x2 + x3 + 2))\nfalse\n\n\n\n"
},

{
    "location": "lib/methods.html#Conversion-of-symbolic-expressions-into-sets-1",
    "page": "Methods",
    "title": "Conversion of symbolic expressions into sets",
    "category": "section",
    "text": "SX.is_halfspace\nSX.is_hyperplane\nSX.is_linearcombination"
},

{
    "location": "about.html#",
    "page": "About",
    "title": "About",
    "category": "page",
    "text": ""
},

{
    "location": "about.html#About-1",
    "page": "About",
    "title": "About",
    "category": "section",
    "text": "This page contains some general information about this project, and recommendations about contributing.Pages = [\"about.md\"]"
},

{
    "location": "about.html#Contributing-1",
    "page": "About",
    "title": "Contributing",
    "category": "section",
    "text": "If you like this package, consider contributing! You can send bug reports (or fix them and send your code), add examples to the documentation or propose new features.Below we detail some of the guidelines that should be followed when contributing to this package."
},

{
    "location": "about.html#Branches-1",
    "page": "About",
    "title": "Branches",
    "category": "section",
    "text": "Each pull request (PR) should be pushed in a new branch with the name of the author followed by a descriptive name, e.g. t/mforets/my_feature. If the branch is associated to a previous discussion in one issue, we use the name of the issue for easier lookup, e.g. t/mforets/7."
},

{
    "location": "about.html#Unit-testing-and-continuous-integration-(CI)-1",
    "page": "About",
    "title": "Unit testing and continuous integration (CI)",
    "category": "section",
    "text": "This project is synchronized with Travis CI, such that each PR gets tested before merging (and the build is automatically triggered after each new commit).For the maintainability of this project, we try to understand and fix the failing doctests if they exist. We develop in Julia v0.6.0, but for experimentation we also build on the nightly branch.To run the unit tests locally, you should do:$ julia --color=yes test/runtests.jl"
},

{
    "location": "about.html#Contributing-to-the-documentation-1",
    "page": "About",
    "title": "Contributing to the documentation",
    "category": "section",
    "text": "This documentation is written in Markdown, and it relies on Documenter.jl to produce the HTML layout. To build the docs, run make.jl:$ julia --color=yes docs/make.jl"
},

{
    "location": "about.html#Credits-1",
    "page": "About",
    "title": "Credits",
    "category": "section",
    "text": "These persons have contributed to SX.jl (in alphabetic order):Marcelo Forets\nNikos Kekatos"
},

]}
