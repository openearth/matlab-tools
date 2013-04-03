function [bmidll] = bmi_new(dll)
header = 'bmi.h';
% header = 'd:\Checkouts\OpenEarthTools\trunk\matlab\applications\bmi\bmi.h';
[dlldir, bmidll, dllext] = fileparts(dll);
addpath(dlldir);
[notfound,warnings] = loadlibrary([bmidll dllext], header);
% TODO: Store header for people who don't have a compiler, 'mfilename', 'bmiheader')
% TODO: check for warnings if no warnings, bmi.h is printed.. pfff
disp(warnings);
% TODO: optional, print functions that are available
% libfunctions(dllname, '-full');
end
