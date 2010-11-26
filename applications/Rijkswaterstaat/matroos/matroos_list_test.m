function ok = matroos_list_test
%MATROOS_LIST_TEST   test for matroos_list
%
%See also: MATROOS

Category(TestCategory.DataAccess);
if TeamCity.running
    TeamCity.ignore('Test requires access to matroos, which the buildserver does not have.');
    return;
end

%% from server: 1st time saves cache: 30 seconds

   tic;

   [locs1,sources1,units1]=matroos_list;

   disp(['matroos_list_test: server: ',num2str(toc),' seconds'])

%% from server: 2nd time uses cache: 30 milliseconds

   tic;

   [locs2,sources2,units2]=matroos_list;

   disp(['matroos_list_test: cache : ',num2str(toc),' seconds'])

%% compare

   ok = 1;
   
   if ~strcmpi(locs1   ,locs2   );ok = 0; return;end
   if ~strcmpi(sources1,sources2);ok = 0; return;end
   if ~strcmpi(units1  ,units2  );ok = 0; return;end

%% EOF
