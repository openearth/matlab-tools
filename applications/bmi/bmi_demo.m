%% The shared library and the generic header file
% Make sure you have setup mex -setup before you run this.
addpath(pwd)

dll = 'd:\checkouts\dflowfm_esmf\bin\debug\unstruc.dll';
config_file = 'd:\checkouts\cases_unstruc\e00_unstruc\f04_bottomfriction\c016_2DConveyance_bend\input\bendprof.mdu';

%% Load the library
[bmidll] = bmi_new(dll);
bmi_initialize(bmidll, config_file);



%%
% Get the node locations
xk = bmi_var_get(bmidll, 'xk');
X = bmi_var_get(bmidll, 'flowelemcontour_x');
yk = bmi_var_get(bmidll, 'yk');
Y = bmi_var_get(bmidll, 'flowelemcontour_y');
% Create online visualization
dt = 1.0;
for i=1:100
    bmi_update(bmidll, dt);
    s1 = bmi_var_get(bmidll, 's1');
    plot3(xk(1:size(s1,1)), yk(1:size(s1,1)), s1, '.')
    zlim([0,6]);
    pause(0.01);
end
bmi_finalize(bmidll)
