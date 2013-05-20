function name = simona2mdf_rmpath(fullname)

% rmpath : removes path from file name

[~,name,ext] = fileparts(fullname);
name         = [name ext];
