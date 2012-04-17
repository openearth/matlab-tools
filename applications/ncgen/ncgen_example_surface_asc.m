% Example script for creating a netcdf from asc source data
% 
%% The basics:
% Netcdf generation with the ncgen toolbox is done by the function
% ncgen_mainFcn. This function does the basics and can be used for many
% different file types / data sets. To do so, the function uses a schema
% function, a read function and a write function:
%
% * schema funtion
%   creates the lay out schema of the netcdf files to write the data to. This
%   schema is usually dependant on the type of data. For surface data, use
%   ncgen_schemaFcn_surface; for timeseries, ncgen_schemaFcn_timeseries.
%
% * read function 
%   Reads the raw data filetype. For a surface data, use
%   ncgen_readFcn_surface_asc.
%
% * writeFcn, 
%   Writes the data to the netcdf file. for surface data use 
%   ncgen_writeFcn_surface.

% %% ceate some dummy data
% % We need some dummy data to write to netcdf. Two asc files are created
% % with different timestamps and coverage;
% dummy_file_location = fullfile(tempdir,'ncgen_example_surface_asc','raw');
% mkpath(dummy_file_location)
% [x,y] = meshgrid(67501:2:69499,446001:2:446999);
% z = [peaks(500)*2 peaks(500)*10];
% 
% asc = [x(:) y(:) z(:)]';
% fid = fopen(fullfile(dummy_file_location,'2012-01-01.asc'),'w');
% fprintf(fid,'%0.0f,%0.0f,%0.1f\n',asc);
% fclose(fid);
% 
% n = (1:1e5)';
% asc = [x(n) y(n) z(n)+2]';
% fid = fopen(fullfile(dummy_file_location,'2012-02-01.asc'),'w');
% fprintf(fid,'%0.0f,%0.0f,%0.1f\n',asc);
% fclose(fid);

%% Define schemaFcn, readFcn and writeFcn
% Define appropriate functions dependant on the dataset as ex[plained
% above. Note that each function requires a fixed set of inputs. 
schemaFcn   = @(OPT)              ncgen_schemaFcn_surface  (OPT);
readFcn     = @(OPT,writeFcn,fns) ncgen_readFcn_surface_asc(OPT,writeFcn,fns);
writeFcn    = @(OPT,data)         ncgen_writeFcn_surface   (OPT,data);

% by passing these functions to the main function, an OPT structure is
% returned that can then be inspecdted to see which properties can be set.
OPT         = ncgen_mainFcn(schemaFcn,readFcn,writeFcn);

% all options available to set are now in OPT. type e.g. 'OPT.read.' and
% press tab to see all read options.

%% OPT.main
% adjust the general settings which apply to every netcdf generation
% define source location
OPT.main.path_source      = 'D:\checkouts\oedata\rijkswaterstaat\vaklodingen\rawer';
OPT.main.file_incl        = '[0-9]{8}\.(asc|ASC)$';
OPT.main.dateFcn          = @(filename) datenum(filename(end-11:end-4),'yyyymmdd');% specify method to extract a datenum from the filename
OPT.main.path_netcdf      = 'F:\nc';%fullfile(tempdir,'ncgen_example_surface_asc','nc');% determine where to write to

%% OPT.schema
% there are settings specific to the schemaFcn.
% To correctly process the test files, define the following:
OPT.schema.EPSGcode       = 28992; % epsg code for Rijksdriehoek
OPT.schema.includeLatLon  = false;
OPT.schema.grid_spacing   = 20;     % x and y coordinates are spaced 2m apart, only on uneven numbers
OPT.schema.grid_offset    = 10;     
OPT.schema.grid_tilesize  = 1000; % put 250 by 250 z points in one nc file

% To save space, we can can specify a different datatype for z than the
% default 64-bits double precision floating point
% a 16 bits integer scaled by 0.1 can hold all data in z and is 4 x smaller
OPT.schema.z_datatype     = 'int16';
OPT.schema.z_scale_factor = 0.002;

% add information about the generating script in the met data.
OPT.schema.meta           = struct(...
    'Conventions'   ,'CF-1.4',...
    'CF_featureType','grid',...
    'title'         ,'Dummy surface data',...
    'institution'   ,'n/a',...
    'source'        ,'n/a',...
    'history'       ,'Created with: $Id$ $HeadURL$',...
    'references'    ,'No reference material available',...
    'comment'       ,'dummy data',...
    'email'         ,'e@mail.com',...
    'version'       ,'1.0',...
    'terms_of_use'  ,'These data is for internal use only!',...
    'disclaimer'    ,'These data are made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');

%% OPT.read
% read settings for the file, we define the following:
OPT.read.zfactor = 0.01;

%% OPT.write
% the defaults are ok

%% call ncgen_mainFcn 
% with the updated data
ncgen_mainFcn(schemaFcn,readFcn,writeFcn,OPT);

%% check results
ncfile = fullfile('F:','nc','x0200010y0600010.nc');

% check structure of one of the nc files created
ncdisp(ncfile);

% check time in the file
datestr(nc_cf_time(ncfile))


z = ncread(ncfile,'z');

surf(max(z,[],3))
hold on
surf(min(z,[],3))
shading flat
camlight

hold on
%%
surf(z(:,:,2))
%%
view(2)
% plot z data for second timestep
figure
surf(    ncread(ncfile,'z',[1 1 2],[inf inf 1]));

hold on

