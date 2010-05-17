function unit = mte_concepttest_test()
unit = 0;

% MTest.name('name of the test');
TeamCity.category('unit'); %'integration','performace', 'KML','DUROS', etc...
if TeamCity.ignore('wip');  return; end

assert(1==2,'1 is not 2')
   