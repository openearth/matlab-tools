function OK = struct2xls_test
%STRUCT2XLS_TEST  unit test for struct2xls
%
%See also: struct2xls, xls2struct

MTestCategory.DataAccess;

if TeamCity.running
    TeamCity.ignore('This test needs Microsoft Office (Excel) to run.');
    return;
end

D.a  = [1 2 3];
D.aT = D.a';
D.b  = {'a','b','c'};  % not OK
D.bT = D.b'; % OK

    struct2xls([mfilename('fullpath'),'.xls'],D,'overwrite',1);
E = xls2struct([mfilename('fullpath'),'.xls']);

% here some dimensions differ ...

OK = ~isequal(D,E);

% ... but values are the same

D.a = D.aT;
D.b = D.bT; % OK

OK = OK & isequal(D,E);

%D.a
%D.b
%E.a
%E.b
