function nan = swan_keyword_test
%test for swan_keyword_test
%
%See also: swan_keyword

keys = {'a','b','c'};

swan_keyword('1 a i'             ,keys) % ok
swan_keyword('a=2 b=b c=j'       ,keys) % ok
swan_keyword('a= 3 b= c c= k'    ,keys) % ok
swan_keyword('a =4 b =d c =l'    ,keys) % ok
swan_keyword('a = 5 b = e c = m' ,keys) % ok

R0.a = '5_default';
R0.b = 'e_default';
R0.c = 'm_default';

swan_keyword('' ,keys)    % special
swan_keyword('' ,keys,R0) % special

