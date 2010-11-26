function OK = swan_keyword_test
%test for swan_keyword_test
%
%See also: swan_keyword

MTestCategory.DataAccess;

keys = {'a','b','c'};

% val

 R(1) = swan_keyword('1 a i'             ,keys); % ok

% key=val, various space options

 R(2) = swan_keyword('a=2 b=b c=j'       ,keys); % ok
 R(3) = swan_keyword('a= 3 b= c c= k'    ,keys); % ok
 R(4) = swan_keyword('a =4 b =d c =l'    ,keys); % ok
 R(5) = swan_keyword('a = 5 b = e c = m' ,keys); % ok

% mixed val and key=val

 R(6) = swan_keyword('a=1 b c=i'         ,keys);

 R0.a = '5_default';
 R0.b = 'e_default';
 R0.c = 'm_default';
 
 R(7) = swan_keyword('' ,keys,R0); % special
 S    = swan_keyword('' ,keys);    % special
 T    = swan_keyword('b=999'         ,keys); % partial (only keywords allowed)
 
% correct answers

 C(1).a = 1;
 C(1).b = 'a';
 C(1).c = 0 + 1.0000i;
 
 C(2).a = 2;
 C(2).b = 'b';
 C(2).c = 0 + 1.0000i;
 
 C(3).a = 3;
 C(3).b = 'c';
 C(3).c = 'k';
 
 C(4).a = 4;
 C(4).b = 'd';
 C(4).c = 'l';
 
 C(5).a = 5;
 C(5).b = 'e';
 C(5).c = 'm';
 
 C(6).a = 1;
 C(6).b = 'a';
 C(6).c = 0 + 1.0000i;
 
 C(7).a = '5_default';
 C(7).b = 'e_default';
 C(7).c = 'm_default';
 
 D.b = 999;
 
% check

 OK = isequal(R(1:5),C(1:5)) & isempty(S) & isequal(T,D);