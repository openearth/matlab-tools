function ok = arcgis2nc_test
%ARCGIS2NC_TEST   unit test for arcgis2nc
%
%see also: ARCGIS2NC, ARCGISREAD

   ok = 1;

   OPT.basename = [fileparts(mfilename('fullpath')),'test',filesep,'test'];

%% create an ascii ascgrid file
   
   fname = [OPT.basename,'.asc'];

   fid = fopen(fname,'w');
   fprintf(fid,'%s\n','ncols        5');
   fprintf(fid,'%s\n','nrows        4');
   fprintf(fid,'%s\n','xllcorner    0'); % lower left is (0,0)
   fprintf(fid,'%s\n','yllcorner    0'); % lower left is (0,0)
   fprintf(fid,'%s\n','cellsize     1');
   fprintf(fid,'%s\n','nodata_value 0');
   fprintf(fid,'%s\n','16 17 18 19 20');
   fprintf(fid,'%s\n','11 12 13 14 15');
   fprintf(fid,'%s\n',' 6  0  8  9 10'); % note one nodatavalue
   fprintf(fid,'%s\n',' 1  2  3  4  5');
   fclose (fid);

%% read it and convert to netCDF

   D   = arcgis2nc([OPT.basename,'.nc' ],...
                   [OPT.basename,'.asc'],...
                                   'epsg',28992,...      % Dutch RD system
                         'convertperline',0,...          % fast conversion (if memory allows)
                                  'units','m',...        % required
                          'standard_name','altitude',... % see: http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/standard-name-table
                              'long_name','z');          % required
                              
   D2  = arcGisRead('test.asc','plot',0);
                              
   D   = arcgis2nc([OPT.basename,'2.nc' ],...
                   D2,...
                                   'epsg',28992,...      % Dutch RD system
                         'convertperline',0,...          % fast conversion (if memory allows)
                                  'units','m',...        % required
                          'standard_name','altitude',... % see: http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/standard-name-table
                              'long_name','z');          % required

%% check

   D3 =  nc2struct([OPT.basename,'.nc' ])

   ok = ok & isequal(D3.x_cen',0:4);
   ok = ok & isequal(D3.y_cen',3:-1:0);
   
   a= [16 17 18 19 20
       11 12 13 14 15
        6  0  8  9 10
        1  2  3  4 5];

   D3.val(isnan(D3.val)) = 0;
   ok = ok & isequal(D3.val',a);
