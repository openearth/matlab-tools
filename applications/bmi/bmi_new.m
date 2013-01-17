function [bmidll] = bmi_new(dll)
header = 'd:\checkouts\dflowfm_esmf\c\bmi_c\bmi.h';
[dlldir, bmidll, dllext] = fileparts(dll);
addpath(dlldir)
loadlibrary([bmidll dllext], header) %, 'mfilename', 'bmiheader')
%Functions that are available
% libfunctions(dllname, '-full');
end
