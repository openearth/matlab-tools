function OK = struct2xls_test
%STRUCT2XLS_TEST  unit test for struct2xls
%
%See also: struct2xls, xls2struct

D.a = [1 2 3]';
D.b = {'a','b','c'};  % not OK
D.b = {'a','b','c'}'; % OK

    struct2xls([mfilename('fullpath'),'.xls'],D);
E = xls2struct([mfilename('fullpath'),'.xls']);

OK = isequal(D,E)

%D.a
%D.b
%E.a
%E.b
