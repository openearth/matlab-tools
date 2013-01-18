function [bmidll] = bmi_new(dll)
header = 'bmi.h';
[dlldir, bmidll, dllext] = fileparts(dll);
addpath(dlldir)
loadlibrary([bmidll dllext], header) %, 'mfilename', 'bmiheader')
%Functions that are available
% libfunctions(dllname, '-full');
end
