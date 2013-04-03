%% The shared library and the generic header file
% Make sure you have setup mex -setup before you run this.
addpath(pwd)

dll = 'd:\Checkouts\swan\branches\feature\esmf\esmf40.91\vs2010\Debug\swan_dll.dll';
config_file = 'd:\Checkouts\swan\branches\feature\esmf\esmf40.91\tests\DMrecSWAN\swan.inp';

%% Load the library
[bmidll] = bmi_new(dll);
bmi_initialize(bmidll, config_file);
bmi_update(bmidll,3600);

%% Get variables
tic
ac2 = bmi_var_get(bmidll, 'AC2');
toc
spcsig = bmi_var_get(bmidll, 'SPCSIG');
ddir = bmi_var_get(bmidll, 'DDIR');
pwtail = bmi_var_get(bmidll, 'PWTAIL');

XCGRID = bmi_var_get(bmidll, 'XCGRID');
YCGRID = bmi_var_get(bmidll, 'YCGRID');

%% Process data

tot = squeeze(sum(sum(ac2,1),2));
tot = tot(1:end-1);

tot2D = reshape(tot,fliplr(size(XCGRID)));


%% Print
surf(double(XCGRID), double(YCGRID), double(tot2D)')


%% cleanup
bmi_finalize(bmidll);
