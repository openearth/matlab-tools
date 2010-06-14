function OK = poly_split_test
%POLY_SPLIT_TEST  test for poly_split
%
%See also: POLY_SPLIT

OK = 1;

%% NaN in middle

   [xc,yc]=poly_split([1 nan 2 3],[4 nan 5 6]);
   
   if ~isequal(xc,{[1],[2 3]}) | ...
      ~isequal(yc,{[4],[5 6]});  OK = 0;
      disp('a')
   end

%% dummy NaN at end

   [xc,yc]=poly_split([1 nan 2 3 nan],[4 nan 5 6 nan]);
   
   if ~isequal(xc,{[1],[2 3]}) | ...
      ~isequal(yc,{[4],[5 6]});  OK = 0;
      disp('b')
   end

%% dummy NaN at start

   [xc,yc]=poly_split([nan 1 nan 2 3],[nan 4 nan 5 6]);
   
   if ~isequal(xc,{[1],[2 3]}) | ...
      ~isequal(yc,{[4],[5 6]});  OK = 0;
      disp('c')
   end

%% dummy NaN at start AND end

   [xc,yc]=poly_split([nan 1 nan 2 3 nan],[nan 4 nan 5 6 nan]);
   
   if ~isequal(xc,{[1],[2 3]}) | ...
      ~isequal(yc,{[4],[5 6]});  OK = 0;
      disp('d')
   end

%% EOF