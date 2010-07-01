function OK = xls2struct_test
%XLS2STRUCT_TEST  unit test for xls2struct
%
%See also: struct2xls, xls2struct

if TeamCity.running
    TeamCity.ignore('This test needs Microsoft Office (Excel) to run.');
    return;
end

%%% aaaaah, this is creating code for nothing....
OK = struct2xls_test;