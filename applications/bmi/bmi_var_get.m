function values = bmi_var_get(bmidll, var)
type_name = char(zeros(1,256));
% TODO FIX THIS
% [name, type_name] = calllib(dllname, 'get_var_type', var, type_name);
type_name = 'double';
rank_ = 0;
[name, rank_] = calllib(bmidll, 'get_var_rank', var, rank_);
% Shape is always zero long
shape = zeros(6,1);
[name, shape] = calllib(bmidll, 'get_var_shape', var, shape);
% Matlab inconvenience (vector==matrix....)
if (rank_ == 1) 
    shape = [shape(rank_),1];
else
    shape = shape(1:rank_);
end
values = zeros(shape);
% Dynamicly create the function name, only int, float and double supported
functionname = sprintf('get_%dd_%s', rank_, type_name);
[name, values] = calllib(bmidll, functionname, var, values);
end