%% The shared library and the generic header file
% Make sure you have setup mex -setup before you run this.
addpath(pwd)

dll = 'd:\checkouts\dflowfm_esmf\bin\debug\unstruc.dll';
config_file = 'd:\checkouts\cases_unstruc\e00_unstruc\f04_bottomfriction\c016_2DConveyance_bend\input\bendprof.mdu';

%% Load the library
[bmidll] = bmi_new(dll);
bmi_initialize(bmidll, config_file);

% Get the node locations
xk = bmi_var_get(bmidll, 'xk');
yk = bmi_var_get(bmidll, 'yk');

% Create online visualization
dt = 1.0;
for i=1:1000
    bmi_update(bmidll, dt);
    s1 = bmi_var_get(bmidll, 's1');
    plot3(xk(1:420), yk(1:420), s1(1:420), '.')
    zlim([0,6]);
end
bmi_finalize(bmidll)
