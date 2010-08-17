function OK = strfindb_test
%STRFINDB_TEST  test for strfindb
%
%See also: STRFINDB, STRFINDBI

[bool1 ,ind1 ] = strfindb ({'aa','ab','bb'},'a');
[bool2 ,ind2 ] = strfindb ({'aa','ab','bb'},'A');
[bool2i,ind2i] = strfindbi({'aa','ab','bb'},'A');

OK = isequal(bool1 ,[1 1 0]) & isequal(ind1 ,[1 2]) & ...
     isequal(bool2 ,[0 0 0]) & isempty(ind2 )       & ...
     isequal(bool2i,[1 1 0]) & isequal(ind2i,[1 2]);