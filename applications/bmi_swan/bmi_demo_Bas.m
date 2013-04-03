close all
clear all
%% The shared library and the generic header file
% Make sure you have setup mex -setup before you run this.
addpath(pwd)

% dll = 'd:\Checkouts\dflowfm_esmf\bin\Debug\unstruc.dll';
% config_file = 'd:\Checkouts\cases_unstruc\e00_unstruc\f04_bottomfriction\c016_2DConveyance_bend\input\bendprof.mdu';

dll = 'd:\Checkouts\dflowfm_esmf\bin\Debug\unstruc.dll';
config_file = 'd:\afstuderen_mapDeltares\03 Elaboration\02 Modelruns\03 Test FM-SWAN\AA01\DMs1dllFM01\MDUC04.mdu';
% config_file = 'd:\afstuderen_mapDeltares\03 Elaboration\02 Modelruns\03 Test FM-SWAN\AA02\UC203.mdu';

%% Load the library
[bmidll] = bmi_new(dll);
bmi_initialize(bmidll, config_file);

% Get the node locations
% xk = bmi_var_get(bmidll, 'xk');     % equals 'NetNode_x'
% yk = bmi_var_get(bmidll, 'yk');

flowelemcontour_x = bmi_var_get(bmidll, 'flowelemcontour_x');   
flowelemcontour_y = bmi_var_get(bmidll, 'flowelemcontour_y');




% Create online visualization
dt = 1.0;
for i=1:2000
    bmi_update(bmidll, dt);
    s1 = bmi_var_get(bmidll, 's1');
%     plot3(xk(1:length(s1)), yk(1:length(s1)), s1(1:end), '.');
%     s1=bsxfun(@times,s1,ones([length(s1) 4]));  % Give s1 2th dimension
%     surf(flowelemcontour_x(1:length(s1),:), flowelemcontour_y(1:length(s1),:), s1(1:end,:));
%     shading flat
%     view(37.5,30)
    plot3(flowelemcontour_x(1:length(s1),:), flowelemcontour_y(1:length(s1),:), s1(1:end,:), '.');
    zlim([-2.5,3]);
    view(0,0)
    title(['i = ' num2str(i)])
    drawnow
end
% bmi_finalize(bmidll)
