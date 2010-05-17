function unit = concepttest_test()
%CONCEPTTEST_TEST  test for concepttest
%
%See also: CONCEPTTEST

unit = 0;

% TeamCity.ignore('wip');  return;
% TeamCity.category('unit','integration','performace') 

assert(1==2,'1 is not 2')
   