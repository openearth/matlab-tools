function OK=path2os_test
%PATH2OS_TEST   test for path2os
%
%See also: path2os

OK = isequal(path2os('/\//\\///\\\////\\\\/////\\\\\//////\\\\\\'),'\') & ...
     isequal(path2os('\\aa\\//\\//'),'\\aa\') & ...
     isequal(path2os('http://www.openeart.nl//'),'http://www.openeart.nl/');