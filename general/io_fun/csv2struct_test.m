function OK = csv2struct_test
%csv2struct_test tets for csv2struct
%
%See also: csv2struct

f = [fileparts(mfilename('fullpath')),filesep,'struct2xls_test.csv']
D = csv2struct(f);

D0.a  = [1 2 3]';
D0.aT = [1 2 3]';
D0.b  = {'a','b','c'}';
D0.bT = {'a','b','c'}';

OK = isequal(D,D0);