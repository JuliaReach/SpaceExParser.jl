This benchmark models a two-dimensional switched oscillator connected to 
filter that smoothes the output signal. The models are parameterized 
over the order (number of 1st-order differential equations) of the
filter.

The oscillator is modeled with 4 locations and 2 continuous variables,
x and y. The filter is a purely continuous system that takes as input 
the value of x, and outputs a smoothened signal z, which depends on x 
via a k-th order system of 1st-order linear differental equations.
The combined system has 4 locations and 2+k continous variables.

