%% SFINCS models to pre-determined extends for FloSup
% v1.0  van Ormondt     10-2020
% v1.1  Leijnse         10-2020
% v2.0  Leijnse         11-2020  - add tidal boundary conditions
% v3.0  Nederhoff       07-2022  - clean version for release
% v4.0  Nederhoff       08-2022  - updated subgrid version
clear variables; close all;

%% 0. Settings
% Add path of where SFINCS scripts are located
% Add also the path where Delft Dashboard is located (is used for bathy)
addpath(genpath('p:\11202255-sfincs\organise_scripts\'))
initialize_bathymetry_database('c:\software\DelftDashboard\data\bathymetry\')

% Define folders and polygons
destin                      = 'p:\11202255-sfincs\organise_scripts\sfincs_modelsetup\example02_FloSup\'; 
include_polygon             = 'include_polygon_flosup.pol';
exclude_polygon             = 'exclude_polygon_flosup.pol';
closed_bnd_polygon          = 'closeboundaries_polygon_flosup_domain01.pol'; 
open_bnd_polygon            = 'openboundaries_polygon_flosup_domain01.pol'; 
openboundary_polyline       = 'openboundaries_polyline_flosup_domain001.pli'; 

% Other settings
tstart                      = datenum(2000,1,1);
tend                        = datenum(2000,2,1);

% Numerical settings
alpha                       = 0.5;          % CFL condition
prefix                      = 'flosup';
dx                          = 200;          % in meter
dy                          = 200;          % ''
subgrid_dx                  = 50;           % '' 
manning_input(1)            = 0.024;        %  manning_deep      -> sea
manning_input(2)            = 0.050;        %  manning_shallow   -> on land
manning_input(3)            = 0.00;         %  manning_level     -> cut-off level

%% 1. Make models
% Find all folders that begin with prefix
cd(destin)
flist=dir([prefix '*']);

% Loop over al domains
for ibox=1:length(flist)
    if flist(ibox).isdir
        
        % Get name and folder 
        disp(['Started with ' flist(ibox).name])
        name            = flist(ibox).name;
        folder          = [name filesep];
        folder_out      = [folder, '_clean', filesep];
        
        %% Make bathmetry
        xml             = xml2struct([folder name '.xml']);
        mmax            = round(str2double(xml.lenx)/dx);
        nmax            = round(str2double(xml.leny)/dy);
        inp             = sfincs_initialize_input;
        inp.depfile     = 'sfincs.dep';
        inp.mskfile     = 'sfincs.msk';
        inp.indexfile   = 'sfincs.ind';
        inp.bndfile     = 'sfincs.bnd';
        inp.bzsfile     = 'sfincs.bzs';
        inp.sbgfile     = 'sfincs.sbg';
        inp.x0          = str2double(xml.x0);
        inp.y0          = str2double(xml.y0);
        inp.mmax        = mmax;
        inp.nmax        = nmax;
        inp.dx          = dx;
        inp.dy          = dy;
        inp.tspinup     = 6*3600;
        inp.rotation    = str2double(xml.rotation);
        inp.alpha       = alpha;
        inp.theta       = 0.95;
        inp.dtout       = 24*3600;
        inp.dthisout    = 600;
        inp.dtmapout    = 3600;
        inp.outputformat = 'net';
        inp.tref        = tstart;
        inp.tstart      = tstart;
        inp.tstop       = tend;
        inp.dtmaxout    = (tend-tstart)*86400;
        inp.dtmaxout    = (tend-tstart)*86400;
        inp.obsfile     = 'noaa_only.obs';
        inp.btfilter    = 600; 
        inp.weirfile    = 'sfincs.weir';
            
        % Find bathymetry sources
        cs.name=xml.csname;
        cs.type=xml.cstype;
        for ib=1:length(xml.bathymetry)
            b=xml.bathymetry(ib).bathymetry;
            bathy(ib).name=b.name;
            bathy(ib).zmin=str2double(b.zmin);
            bathy(ib).zmax=str2double(b.zmax);
            bathy(ib).vertical_offset=str2double(b.vertical_offset);
        end

        % Get ready to call the script
        xy_in           = [folder, include_polygon];
        xy_ex           = [folder, exclude_polygon]; 
        xy_bnd_closed   = [folder, closed_bnd_polygon];
        xy_bnd_open     = [folder, open_bnd_polygon];
        
        % Make new folder
        sfincs_build_model(inp,folder_out,bathy,cs,'gridout', 0, 'includepolygon',xy_in, 'excludepolygon',xy_ex,'openboundarypolygon',xy_bnd_open, ...
            'closedboundarypolygon',xy_bnd_closed,'subgrid_dx',subgrid_dx, 'manning_input', manning_input);
        clear xy_in   xy_ex xy_bnd_closed xy_bnd_open
        
        %% Make boundary + conditions
        % Make boundary points
        fname           = [folder, openboundary_polyline];
        data            = tekal('read',fname,'loaddata');
        np              = length(data.Field);
        for ip=1:np
            x=data.Field(ip).Data(:,1);
            y=data.Field(ip).Data(:,2);
            if x(end)~=x(1) || y(end)~=y(1)
                x=[x;x(1)];
                y=[y;y(1)];
            end
            p(ip).x=x;
            p(ip).y=y;
        end
        p.length = length(p.x);
        sfincs_write_boundary_points([destin,folder_out,'sfincs.bnd'],p)

        % Convert to WGS84
        [x_wgs84, y_wgs84] = convertCoordinates(p.x, p.y, 'CS2.name','WGS 84','CS2.type','geo','CS1.name',cs.name,'CS1.type',cs.type);
        
        % Get tidal data for all the points
        name            ='tpxo80'; %handles.tideModels.model(ii).name;
        URL             = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/delftdashboard/tidemodels/tpxo80';
        if strcmpi(URL(1:4),'http')
            tidefile    =[URL '/' name '.nc'];
        else
            tidefile    =[URL filesep name '.nc'];
        end
        [gt,conList]    =  read_tide_model(tidefile,'type','h','x',x_wgs84','y',y_wgs84','constituent','all');
        
        % Loop over points
        for jj = 1:p.length
            
            % Get time
            t0      = inp.tstart; 
            t1      = inp.tstop; datenum(2018,09,31);
            dt      = 10/1440; 
            tim     = t0:dt:t1;
            
            % Tidal prediction
            latitude=y_wgs84(jj);
            wl=makeTidePrediction(tim,conList,gt.amp(:,jj),gt.phi(:,jj),latitude);
                        
            % Save information
            tide(jj).x      = p.x(jj);
            tide(jj).y      = p.y(jj);
            tide(jj).time   = tim;
            tide(jj).bzs    = wl;
            bzsall(:,jj)    = wl;
        end
        t   = (tim - tim(1)) * 24*3600;
        sfincs_write_boundary_conditions([destin,folder_out,'sfincs.bzs'],t,bzsall)
        
        %% Determine weirs for domain
        % Use existing polyline to find highest point in so-called obstacle file
        obstacle=sfincs_get_obstacles('weir_polygon.pli',200,100,cs,bathy);
        
        % Write it out
        cd(folder_out)
        sfincs_write_obstacle_file(inp.weirfile,obstacle);
        
        % Done with this iteration
        
    end
end
