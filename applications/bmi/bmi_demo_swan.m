%% The shared library and the generic header file
% Make sure you have setup mex -setup before you run this.
addpath(pwd)

dll = 'D:\checkouts\swanesmf\esmf40.91\vs2010\Debug\swan_dll.dll';
config_file = 'D:\checkouts\swanesmf\esmf40.91\tests\DMrecSWAN\swan.inp';

%% Load the library
[bmidll] = bmi_new(dll);
bmi_initialize(bmidll, config_file);
bmi_update(bmidll,-1);

%% Get variables
ac2 = bmi_var_get(bmidll, 'AC2');
spcsig = bmi_var_get(bmidll, 'SPCSIG');
ddir = bmi_var_get(bmidll, 'DDIR');
pwtail = bmi_var_get(bmidll, 'PWTAIL');

%% cleanup
bmi_finalize(bmidll);
