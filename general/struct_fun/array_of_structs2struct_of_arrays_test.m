function OK = array_of_structs2struct_of_arrays_test
%ARRAY_OF_STRUCTS2STRUCT_OF_ARRAYS_TEST    test for array_of_structs2struct_of_arrays
%
%See also: ARRAY_OF_STRUCTS2STRUCT_OF_ARRAYS

%% input

   D(1).a = [1,2];
   D(1).b = [1;2];
   D(1).c = 'lampje';
   D(1).d = {'lampje'};
   
   D(2).a = [3,4];
   D(2).b = [3;4];
   D(2).c = 'oregon';
   D(2).d = {'oregon'};
   
%% desired answer

   T.a(1,1,:) = [1 2];
   T.a(2,1,:) = [3 4];
   
   T.b(1,:) = [1 2];
   T.b(2,:) = [3 4];
   
   T.c = {D(1).c,D(2).c}; 
   
   T.d = {D(1).d{1},D(2).d{1}}; 
   
%% actual answer

   T2 = array_of_structs2struct_of_arrays(D);
   
   OK = isequal(T,T2);

%% EOF