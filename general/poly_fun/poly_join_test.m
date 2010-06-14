function OK = poly_join_test
%POLY_JOIN_TEST  unit test for poly_join
%
%See also: POLY_JOIN_TEST

 x = {[2 3],[4 5 6],[ 7 8 9 10]};
OK = isequal(poly_split(poly_join(x)),x)
