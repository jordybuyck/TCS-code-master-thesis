The model parameters in the code ('ReducedScopePhillips.jl') are now set to obtain results from the endogenous model, so if one just run the code without any changes, this model will be build.
In order to obtain the results from other models, the corresponding model parameters should be adapted.
This can be done by adapting the code based on the table in 'ModelParameters.xlsx'.
Each row is a different model and each column specifies which line(s) has(ve) to be adapted in the code.

For example, when you want to obtain the results from the endogenous model with storage and with a time resolution of 1h, then the '#' in the code of that model should be removed.
The corresponding model parameter lines in the code are located both under the line to build the specific model, and in previous line codes.
The model parameters can be set to the right value (e.g. "yes" or "no") that corresponds to that model, which can be found in the table in 'ModelParameters.xlsx'.
In order to find the model parameters in the code more easily, one could use 'ctrl + F' and search for ' = "yes"' &  ' = "no"' (important to use space before equal sign).
When all model parameters are set right, then one could run the code in order to obtain the results from that specific model.