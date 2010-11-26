function OK = xls2struct_test
%XLS2STRUCT_TEST  unit test for xls2struct
%
%See also: struct2xls, xls2struct

MTestCategory.DataAccess;

if TeamCity.running
    TeamCity.ignore('This test needs Microsoft Office (Excel) to run.');
    return;
end

%% in https://repos.deltares.nl/repos/OpenEarthTools/test/

T(1).a  = [1 2 3]';
T(1).b  = {'aa','dd','gg'}';
T(1).c  = [1 2 3]';

T(2).a = [1 2 3]';
T(2).b = {'aa','dd','gg'}';
T(2).c = [1 2 3;4 5 6]';

T(3).a = [1 2 3]';
T(3).b = {'aa','dd','gg'}';
T(3).c = {{'bb','cc'},{'ee','ff'},{'hh','ii'}}';

T(4).a = [1 2 3]';
T(4).b = {'aa','dd','gg'}';
T(4).c = {{'bb','cc'},[2 5],{'hh',6}}';


D(1) = xls2struct('xls2struct_test.xls','1Donly');
D(2) = xls2struct('xls2struct_test.xls','2Dnum' ,'last2d',1);
D(3) = xls2struct('xls2struct_test.xls','2Dchar','last2d',1);
D(4) = xls2struct('xls2struct_test.xls','2Dmisc','last2d',1);

for i=1:length(T)

   OK(i) = isequal(D(i),T(i));

end


OK = all(OK);