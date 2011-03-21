function ok = ArcGisRead_test
%ARCGISREAD_TEST   unit test for ArcGisRead
%
%see also: ARCGIS2NC, ARCGISREAD

   OPT.nc = 0;

   ok = 1;

   OPT.basename = fullfile(fileparts(mfilename('fullpath')),'test');

%% create an ascii ascgrid file
   
   fname = [OPT.basename,'.asc'];

   fid = fopen(fname,'w');
   fprintf(fid,'%s\n','ncols        5');
   fprintf(fid,'%s\n','nrows        4');
   fprintf(fid,'%s\n','xllcorner    0'); % lower left is (0,0), so ...
   fprintf(fid,'%s\n','yllcorner    0'); % first data point is at located at ...
   fprintf(fid,'%s\n','cellsize     1'); % (0.5 ,0.5)
   fprintf(fid,'%s\n','nodata_value 0');
   fprintf(fid,'%s\n','16 17 18 19 20');
   fprintf(fid,'%s\n','11 12 13 14 15');
   fprintf(fid,'%s\n',' 6  0  8  9 10'); % note one nodatavalue
   fprintf(fid,'%s\n',' 1  2  3  4  5');
   fclose (fid);

%% read

   D2  = arcGisRead('test.asc','plot',0,'nc',OPT.nc,'units','m','long_name','depth');

%% check upwardy

  [D3.x D3.y D3.val] = arcGisRead('test.asc','upwardy',1); %arc_asc_read('test.asc');
  
   ok = ok & isequal(D3.x  ,D2.x);
   ok = ok & isequal(D3.y  ,fliplr(D2.y));
   ok = ok & isequalwithequalnans(D3.val,flipud(D2.val));

%% check

   ok = ok & isequal(D2.x,[0:+1:4]+.5);
   ok = ok & isequal(D2.y,[3:-1:0]+.5);
   
   a= [16  17 18 19 20
       11  12 13 14 15
        6 nan  8  9 10
        1   2  3  4 5];

   ok = ok & isequalwithequalnans(D2.val,a);

%% check nc

   if OPT.nc
   D4 = nc2struct('test.nc');
   ok = ok & isequal(D4.x(:)  ,D2.x(:));
   ok = ok & isequal(D4.y(:)  ,D2.y(:));
   ok = ok & isequalwithequalnans(D4.val,D2.val);
   end

