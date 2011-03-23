%function nc_multibeam_from_asc_test(varargin)
%NC_MULTIBEAM_FROM_ASC_TEST   unit test for nc_multibeam_from_asc
%
%see also: arcgis, nc_multibeam, ArcGisRead_test

   timefmt  = 'yyyymmdd';
   basename = fullfile(fileparts(mfilename('fullpath')),datestr(now,timefmt));

%% create an ascii ascgrid file (same as tst for arc_asc_read)
   
   
   
   %      Input:
   %           +-------------+ LL
   %      |          +-------------+ UR
   %      |  .  .  .  .  .  .  .  .  .  .  .  .
   %      |  .  .  .  .  .  .  .  .  .  .  .  .
   %      |  .  .  . 36 37 38 39 40  .  .  .  .
   %      |  .  .  . 31 32 33 34 35  .  .  .  .
   %     _|  . 16 17 26 20 28 29 30  .  .  .  .
   %      |  . 11 12 21 22 23 24 25  .  .  .  .
   %      |  .  6  0  8  9 10  .  .  .  .  .  .
   %      |  .  1  2  3  4  5  .  .  .  .  .  .
   %      |  .  .  .  .  .  .  .  .  .  .  .  .
   %      +------------------+------------------+
   %                         
   %      Output:

   fname = [basename,'LL.asc'];
   fid = fopen(fname,'w');
   fprintf(fid,'%s\n','ncols        5'); % nx
   fprintf(fid,'%s\n','nrows        4'); % ny
   fprintf(fid,'%s\n','xllcorner    0'); % lower left is (0,0), so ...
   fprintf(fid,'%s\n','yllcorner    0'); % first data point is at located at ...
   fprintf(fid,'%s\n','cellsize     1'); % (0.5 ,0.5)
   fprintf(fid,'%s\n','nodata_value 0');
   fprintf(fid,'%s\n','16 17 18 19 20');
   fprintf(fid,'%s\n','11 12 13 14 15');
   fprintf(fid,'%s\n',' 6  0  8  9 10'); % note one nodatavalue
   fprintf(fid,'%s\n',' 1  2  3  4  5');
   fclose (fid);

   fname = [basename,'UR.asc'];
   fid = fopen(fname,'w');
   fprintf(fid,'%s\n','ncols        5'); % nx
   fprintf(fid,'%s\n','nrows        4'); % ny
   fprintf(fid,'%s\n','xllcorner    2'); % lower left is (0,0), so ...
   fprintf(fid,'%s\n','yllcorner    2'); % first data point is at located at ...
   fprintf(fid,'%s\n','cellsize     1'); % (0.5 ,0.5)
   fprintf(fid,'%s\n','nodata_value 0');
   fprintf(fid,'%s\n','36 37 38 39 40');
   fprintf(fid,'%s\n','31 32 33 34 35');
   fprintf(fid,'%s\n','26 20 28 29 30'); % note one nodatavalue
   fprintf(fid,'%s\n','21 22 23 24 25');
   fclose (fid);

%% create

   OPT.make                = true;
   
   OPT.basepath_local      = fileparts(basename);
   OPT.basepath_network    = fileparts(basename);
   OPT.basepath_opendap    = fileparts(basename);
   OPT.raw_path            = fileparts(basename);
   OPT.raw_extension       = [filename(basename),'*.asc'];
   OPT.netcdf_path         = '';
   OPT.cache_path          = fullfile(tempdir,'nc_asc');
   OPT.zip                 = false;         % are the files zipped?
   OPT.zip_extension       = '*.zip';       % zip file extension
   
   OPT.datatype            = 'multibeam';
   OPT.EPSGcode            = 28992;
   OPT.dateFcn             = @(s) datenum(monthstr_mmm_dutch2eng(s(1:8)),'yyyy mmm'); % how to extract the date from the filename
   
   OPT.mapsizex            = 5+1;             % size of fixed map in x-direction
   OPT.mapsizey            = 4+1;             % size of fixed map in y-direction
   OPT.gridsizex           = 1;               % x grid resolution
   OPT.gridsizey           = 1;               % y grid resolution
   OPT.xoffset             = -OPT.gridsizex/2; % zero point of x grid (x of data points, not of pixels corners)
   OPT.yoffset             = -OPT.gridsizey/2; % zero point of y grid (x of data points, not of pixels corners)
   OPT.dateFcn             = @(s)datenum(s(1:length(timefmt)),timefmt);
   
   ncfiles = nc_multibeam_from_asc(OPT)

%% load

   for i=1:length(ncfiles)
   D(i) = nc2struct(ncfiles{i});
   end
   
   D().z

%% check

   ok = 1;

   ok = ok & isequal(D(1).x',[0:+1:5]-0.5)
   ok = ok & isequal(D(2).x',[0:+1:5]-0.5)
   ok = ok & isequal(D(3).x',[0:+1:5]+5.5)
   ok = ok & isequal(D(4).x',[0:+1:5]+5.5)
   
   ok = ok & isequal(D(1).y',[4:-1:0]-0.5)
   ok = ok & isequal(D(2).y',[4:-1:0]+4.5)
   ok = ok & isequal(D(3).y',[4:-1:0]-0.5)
   ok = ok & isequal(D(4).y',[4:-1:0]+4.5)
   
   a1= [   NaN    16    17    26    20    28
           NaN    11    12    21    22    23
           NaN     6   NaN     8     9    10
           NaN     1     2     3     4     5
           NaN   NaN   NaN   NaN   NaN   NaN];
   
   a2= [   NaN   NaN   NaN   NaN   NaN   NaN
           NaN   NaN   NaN   NaN   NaN   NaN
           NaN   NaN   NaN   NaN   NaN   NaN
           NaN   NaN   NaN    36    37    38
           NaN   NaN   NaN    31    32    33];

   a3= [    29    30   NaN   NaN   NaN   NaN
            24    25   NaN   NaN   NaN   NaN
           NaN   NaN   NaN   NaN   NaN   NaN
           NaN   NaN   NaN   NaN   NaN   NaN
           NaN   NaN   NaN   NaN   NaN   NaN];

   a4= [   NaN   NaN   NaN   NaN   NaN   NaN
           NaN   NaN   NaN   NaN   NaN   NaN
           NaN   NaN   NaN   NaN   NaN   NaN
            39    40   NaN   NaN   NaN   NaN
            34    35   NaN   NaN   NaN   NaN];

   ok = ok & isequalwithequalnans(D(1).z,a1)
   ok = ok & isequalwithequalnans(D(2).z,a2)
   ok = ok & isequalwithequalnans(D(3).z,a3)
   ok = ok & isequalwithequalnans(D(4).z,a4)
   