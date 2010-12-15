function OK = array_of_structs2struct_of_arrays_test
%ARRAY_OF_STRUCTS2STRUCT_OF_ARRAYS_TEST    test for array_of_structs2struct_of_arrays
%
%See also: ARRAY_OF_STRUCTS2STRUCT_OF_ARRAYS

%% input

   D(1).a = [1,nan];
   D(1).b = [1;2];
   D(1).c = 'lampje';
   D(1).d = {'lampje'};
   D(1).e = [1 2 3 4];
   D(1).f = [1 2 3 4];
   
   D(2).a = [3,4];
   D(2).b = [3;4];
   D(2).c = 'oregon';
   D(2).d = {'oregon'};
   D(2).e = [1 2 3 4 5 6]; % odd size
   D(2).f = []; % odd size
   
%% desired answer

   T.a(1,1,:) = [1 nan];
   T.a(2,1,:) = [3 4];
   
   T.b(1,:) = [1 2];
   T.b(2,:) = [3 4];
   
   T.c = {D(1).c,D(2).c}; 
   
   T.d = {D(1).d{1},D(2).d{1}}; 
   
%% check default and IgnoreErrors==1

   T2 = array_of_structs2struct_of_arrays(D,'IgnoreErrors',1);
   
   % this one should crash

   try
      T3 = array_of_structs2struct_of_arrays(D);
      OK = 0;
   catch
      OK = 1;
   end
   
   OK = isequalwithequalnans(T,T2) & OK;

%% EOF