% function ok = ArcGisRead_test
%ARCGISREAD_TEST   unit test for ArcGisRead
%
%see also: ARCGIS2NC, ARCGISREAD

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

   D2  = arcGisRead('test.asc','plot',0);
  [D3.x D3.y D3.val] = arc_asc_read('test.asc')
  
%% check

   ok = ok & isequal(D2.x,[0:+1:4]+.5)
   ok = ok & isequal(D2.y,[3:-1:0]+.5)
   
   a= [16 17 18 19 20
       11 12 13 14 15
        6  0  8  9 10
        1  2  3  4 5];

   D2.val(isnan(D2.val)) = 0;
   ok = ok & isequal(D2.val,a);
