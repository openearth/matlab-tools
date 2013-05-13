function varargout = vs_trih2nc(vsfile,varargin)
%vs_trih2nc  Convert part of a Delft3D trih file to netCDF-CF
%
%   vs_trih2nc(NEFISfile,<'keyword',value>)
%   vs_trih2nc(NEFISfile,<netCDFfile>,<'keyword',value>)
%
% converts Delft3D trih file (NEFIS file) to a netCDF file which has
% default name <RUNID>_his.nc to conform with default dflowfm history output.
% Do specify timezone and epsg code, to conform to CF standard and facilitate reuse.
%
% Example:
%
%   vs_trih2nc('P:\aproject\trih-n15.dat','epsg',28992,'timezone',timezone_code2iso('GMT'))
%
% nc looks same as history nc of dflowfm, so be used in dflowfm.analyseHis, and
% loads well into Quickplot. 
%
% Example how to use this netCDF file: read all
%   H = nc2struct(ncfile)
%
% Example how to use this netCDF file: select one platform
%   dflowfm.indexHis(ncfile,<platform_name>);
%   ind = 48;
%   D.platform_name = nc_varget (ncfile,'platform_name',[  ind-1 0],[ 1 -1   ]);
%   D.eta           = nc_varget (ncfile,'waterlevel'   ,[0 ind-1  ],[-1  1   ]);
%   D.u             = nc_varget (ncfile,'u_x'          ,[0 ind-1 0],[-1  1 -1]);
%   D.v             = nc_varget (ncfile,'u_y'          ,[0 ind-1 0],[-1  1 -1]);
%   D.dep           = nc_varget (ncfile,'depth'        ,[  ind-1  ],[1]);
%   D.datenum       = nc_cf_time(ncfile)
%
% Note:  you can make an nc_dump cdl ascii file a char for keyword dump:
%        vs_trih2nc('tst.dat','dump','tst.cdl');
% Note:  you can save only a subset of stations, or reorder them, to netCDF file with keyword 'ind'
%
%See also: vs_trim2nc for trim-*.dat delft3d-flow map file,
%          netcdf, snctools, vs_use, dflowfm, delft3d_io_obs, dflowfm.indexHis, dflowfm.analyseHis

% TO DO add morphological! depth
% TO DO check consistency with delft3d_to_netcdf.exe of Bert Jagers
% TO DO add sediment, turbulence etc
% TO DO add cell methods to xcor = mean(x)
% to do merge with OpenEarthTools\matlab\applications\cosmos\code\OMSRunner\fileio\trih2nc

%%  --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

%% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
%  OpenEarthTools is an online collaboration to share and manage data and 
%  programming tools in an open source, version controlled environment.
%  Sign up to recieve regular updates of this function, and to contribute 
%  your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
%  $Id$
%  $Date$
%  $Author$
%  $Revision$
%  $HeadURL$
%  $Keywords: $

%% keywords
    
    OPT.Format         = 'classic'; % '64bit','classic','netcdf4','netcdf4_classic'
    OPT.refdatenum     = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wrong dates in ncbrowse due to different calendars. Must use doubles here.
    OPT.refdatenum     = datenum(1970,1,1); % linux  datenumber convention
    OPT.institution    = '';
    OPT.timezone       = ''; %timezone_code2iso('GMT');
    OPT.epsg           = [];
    OPT.type           = 'single'; %'double'; % the nefis file is by default single precision, se better isn't useful
    OPT.debug          = 0;
    OPT.time           = 0; % subset of time indices in NEFIS file, 1-based
    OPT.dump           = 1;

    OPT.quiet          = 'quiet';
    OPT.stride         = 0; % write chunks per layer in case of large 3D matrices
    OPT.ind            = 0; % index of stations to include in netCDF file, 0=all
    OPT.crsind         = 0; % index of cross-sections to include in netCDF file, 0=all
    OPT.trajectory     = 0; % consider 'Stations' dimension as spatial trajectory dimension
    OPT.name           = ''; % addition to nc-filename
      % TO DO: allow to transform sub-period too.
      % TO DO: implement WI and PI from griddata_near2, and add rename dimension 'Station' to 'distance'
      % TO DO: make QP fit for trajectory plotting
      
    if nargin==0
        varargout = {OPT};
        return
    end

    if verLessThan('matlab','7.12.0.635')
        error('At least Matlab release R2011a is required for writing netCDF files due tue NCWRITESCHEMA.')
    end

    if ~odd(nargin)
        ncfile   = varargin{1};
        varargin = {varargin{2:end}};
        OPT      = setproperty(OPT,varargin{:});
    else
        OPT      = setproperty(OPT,varargin{:});
        runid    = filename(vsfile); runid = runid(6:end); % remove 'trih-'
        ncfile   = fullfile(fileparts(vsfile),[runid,'_his',OPT.name,'.nc']); % '_his' is same as Delft3D-FM
    end

    tmp=dir(vsfile);
    if isempty(tmp)
        error(['file does not exist: ',vsfile])
    end
    if (tmp.bytes > 2^31) & strcmpi(OPT.Format,'classic')
        fprintf(2,'> Delft3D NEFIS files larger than 2 Gb cannot be mapped entirely to netCDF classic format, set keyword vs_trim2nc(...,''Format'',''64bit'').\n')
    end
   
%% 0 Read raw data

    F = vs_use(vsfile,'quiet');

    if ~strcmp(F.SubType,'Delft3D-trih')
        error([mfilename ' works only for Delft3D-trih file, perhaps you needed vs_trim2nc for the Delft3D-trim file.'])
    end

    disp('Reading time...')
    T.datenum = vs_time(F,OPT.time,'quiet');
    if OPT.time==0
        OPT.time = 1:length(T.datenum);
    end
    I = vs_get_constituent_index(F);

    M.datestr     = datestr(datenum(vs_get(F,'his-version','FLOW-SIMDAT' ,'quiet'),'yyyymmdd  HHMMSS'),31);
    M.version     = [strtrim(vs_get(F,'his-version','FLOW-SYSTXT' ,'quiet')),', file version: ',...
                     strtrim(vs_get(F,'his-version','FILE-VERSION','quiet'))];
    M.description = vs_get(F,'his-version','FLOW-RUNTXT',OPT.quiet);

%% 1a Create file (add all NEFIS 'map-version' group info)

    % Add overall meta info
    % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents

    nc = struct('Name','/','Format',OPT.Format);
    nc.Attributes(    1) = struct('Name','title'              ,'Value',  '');
    nc.Attributes(end+1) = struct('Name','institution'        ,'Value',  OPT.institution);
    nc.Attributes(end+1) = struct('Name','source'             ,'Value',  'Delft3D trih file');
    nc.Attributes(end+1) = struct('Name','history'            ,'Value', ['Original filename: ',filenameext(vsfile),...
                                     ', ' ,M.version,...
                                     ', file date:',M.datestr,...
                                     ', transformation to netCDF: $HeadURL$ $Id$']);
    nc.Attributes(end+1) = struct('Name','references'         ,'Value',  'http://svn.oss.deltares.nl');
    nc.Attributes(end+1) = struct('Name','email'              ,'Value',  '');

    nc.Attributes(end+1) = struct('Name','comment'            ,'Value',  '');
    nc.Attributes(end+1) = struct('Name','version'            ,'Value',  M.version);

    nc.Attributes(end+1) = struct('Name','Conventions'        ,'Value',  'CF-1.6');

    nc.Attributes(end+1) = struct('Name','terms_for_use'      ,'Value', ['These data can be used freely for research purposes provided that the following source is acknowledged: ',OPT.institution]);
    nc.Attributes(end+1) = struct('Name','disclaimer'         ,'Value',  'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');

    nc.Attributes(end+1) = struct('Name','delft3d_description','Value',  str2line(M.description));

    % ISO metadata "WHEN": http://www.unidata.ucar.edu/software/netcdf-java/formats/DataDiscoveryAttConvention.html
    % https://geo-ide.noaa.gov/wiki/index.php?title=NetCDF_Attribute_Convention_for_Dataset_Discovery

    nc.Attributes(end+1) = struct('Name','time_coverage_start','Value',  datestr(T.datenum(  1),'yyyy-mm-ddTHH:MM'));
    nc.Attributes(end+1) = struct('Name','time_coverage_end'  ,'Value',  datestr(T.datenum(end),'yyyy-mm-ddTHH:MM'));

    %% Coordinate system

    disp('Reading coordinates...')
    G.kmax        =                 vs_let(F,'his-const','KMAX'              ,'quiet');
    G.coordinates = strtrim(permute(vs_let(F,'his-const','COORDINATES'       ,'quiet'),[1 3 2]));

    G.m           =         squeeze(vs_let(F,'his-const','MNSTAT',{1,OPT.ind},'quiet'));
    G.n           =         squeeze(vs_let(F,'his-const','MNSTAT',{2,OPT.ind},'quiet'));

    G.angle       =         squeeze(vs_let(F,'his-const','ALFAS' ,{  OPT.ind},'quiet'));
    G.kmax        =         squeeze(vs_let(F,'his-const','KMAX'  ,            'quiet'));
    G.name        =         permute(vs_let(F,'his-const','NAMST' ,{  OPT.ind},'quiet'),[2 3 1]);

    if ~isempty(vs_get_elm_def(F,'NAMTRA')) && ~isempty(OPT.crsind)
        G.crsm    =         squeeze(vs_let(F,'his-const','MNTRA' ,{[1,3],OPT.crsind},'quiet'));
        G.crsn    =         squeeze(vs_let(F,'his-const','MNTRA' ,{[2,4],OPT.crsind},'quiet'));
        G.crsname =         permute(vs_let(F,'his-const','NAMTRA',{      OPT.crsind},'quiet'),[2 3 1]);
    end

    % real and transform world coordinates
    %  define coordinate attribute

    if any(strfind(G.coordinates,'CART')) % CARTESIAN, CARTHESIAN (old bug)
        G.x           = squeeze(vs_let(F,'his-const','XYSTAT',{1,OPT.ind}      ,'quiet'));
        G.y           = squeeze(vs_let(F,'his-const','XYSTAT',{2,OPT.ind}      ,'quiet'));
        coordinates   = 'x y';

        if ~isempty(vs_get_elm_def(F,'NAMTRA')) && ~isempty(OPT.crsind)
            G.crsx        = squeeze(vs_let(F,'his-const','XYTRA',{[1,3],OPT.crsind},'quiet'));
            G.crsy        = squeeze(vs_let(F,'his-const','XYTRA',{[2,4],OPT.crsind},'quiet'));
        end

        if ~(isempty(OPT.epsg)||isnan(OPT.epsg))
            [G.lon,G.lat]       = convertCoordinates(G.x,   G.y,   'CS1.code',OPT.epsg,'CS2.code',4326);
            if ~isempty(vs_get_elm_def(F,'NAMTRA')) && ~isempty(OPT.crsind)
                [G.crslon,G.crslat] = convertCoordinates(G.crsx,G.crsy,'CS1.code',OPT.epsg,'CS2.code',4326);
            end
        else
            fprintf(2,'> No EPSG code specified for CARTESIAN grid, your grid is not CF compliant:\n')
            fprintf(2,'> (latitude,longitude) cannot be calculated from (x,y)!\n')
        end

    else
      G.lon         = squeeze(vs_let(F,'his-const','XYSTAT',{1,OPT.ind},'quiet'));
      G.lat         = squeeze(vs_let(F,'his-const','XYSTAT',{2,OPT.ind},'quiet'));
      coordinates   = 'latitude longitude';

      if ~isempty(vs_get_elm_def(F,'NAMTRA')) && ~isempty(OPT.crsind)
        G.crslon    = squeeze(vs_let(F,'his-const','XYTRA',{[1,3],OPT.crsind},'quiet'));
        G.crslat    = squeeze(vs_let(F,'his-const','XYTRA',{[2,4],OPT.crsind},'quiet'));
      end

      if ~(isempty(OPT.epsg)||isnan(OPT.epsg))
        [G.x     ,G.y     ] = convertCoordinates(G.lon,   G.lat,   'CS1.code',4326,'CS2.code',OPT.epsg);
        if ~isempty(vs_get_elm_def(F,'NAMTRA')) && ~isempty(OPT.crsind)
            [G.crsx  ,G.crsy  ] = convertCoordinates(G.crslon,G.crslat,'CS1.code',4326,'CS2.code',OPT.epsg);      
        end
      end

    end
   
   % vertical: z/sigma
    G.layer_model = strtrim(permute(vs_let(F,'his-const','LAYER_MODEL','quiet'),[1 3 2]));

    if strmatch('SIGMA-MODEL', G.layer_model)
        G.sigma_dz      =  vs_let(F,'his-const','THICK','quiet');   
        [G.sigma_cent,...
        G.sigma_intf]   = d3d_sigma(G.sigma_dz);
        coordinatesLayer        = [coordinates]; % implicit via formula_terms att
        coordinatesLayerInterf  = [coordinates]; % implicit via formula_terms att
    elseif strmatch('Z-MODEL', G.layer_model)
        fprintf(2,'> Z-MODEL has not yet been tested.\n')
        G.ZK          =  vs_let(F,'his-const'     ,'ZK'               ,'quiet');
        coordinatesLayer        = [coordinates]; % ' Layer'
        coordinatesLayerInterf  = [coordinates]; % ' LayerInterf'
    end

    %% sediment fractions
    if ~isempty(strmatch('sediment',fieldnames(I)))
        G.lsed   = vs_let(F,'his-const','LSED','quiet');
        G.namsed = strtrim(squeeze(vs_let(F,'his-const','NAMSED','quiet')));
        for jj=1:G.lsed
            G.sedind(jj) = I.(lower(strtrim(squeeze(G.namsed(jj,:))))).index;
        end
    else G.lsed = 0;
        G.namsed = '';
    end
   
%% 2 Create dimensions

    ncdimlen.time        = length(T.datenum);
    ncdimlen.Layer       = G.kmax  ;
    ncdimlen.LayerInterf = G.kmax+1;
    ncdimlen.Fraction    = G.lsed  ;

    nc.Dimensions(    1) = struct('Name','time'            ,'Length',ncdimlen.time       );
    nc.Dimensions(end+1) = struct('Name','Layer'           ,'Length',ncdimlen.Layer      );
    nc.Dimensions(end+1) = struct('Name','LayerInterf'     ,'Length',ncdimlen.LayerInterf);
    nc.Dimensions(end+1) = struct('Name','Fraction'        ,'Length',ncdimlen.Fraction   );

    if OPT.trajectory
        nc.Attributes(end+1) = struct('Name','featureType'        ,'Value',  'trajectoryProfile');
        dimname = 'Trajectory';
        if isfield(G,'x')
            G.trajectory = distance(G.x,G.y);
        else
            G.trajectory = nan.*G.lon;
            fprintf(2,'> trajectory has no distance: spherical coordinates need epsg code to calculate Euclidian distance.\n')
        end
    else
        nc.Attributes(end+1) = struct('Name','featureType'        ,'Value',  'timeSeries');
        dimname = 'Station';
        ncdimlen.station_name_len = size(G.name,2);
        nc.Dimensions(end+1) = struct('Name','station_name_len'   ,'Length',ncdimlen.station_name_len);
    end

    ncdimlen.(dimname) = size(G.name,1);
    nc.Dimensions(end+1) = struct('Name',dimname               ,'Length',ncdimlen.(dimname));

    if ~isempty(vs_get_elm_def(F,'NAMTRA')) && ~isempty(OPT.crsind)
        dimname2 = 'Crosssection';
        ncdimlen.x_section_name_len = size(G.crsname,2);
        nc.Dimensions(end+1) = struct('Name','x_section_name_len' ,'Length',ncdimlen.x_section_name_len);

        ncdimlen.(dimname2) = size(G.crsname,1);
        nc.Dimensions(end+1) = struct('Name',dimname2             ,'Length',ncdimlen.(dimname2));
        nc.Dimensions(end+1) = struct('Name','start_end'          ,'Length',2);
    end

      
%% 2 Create dimension combinations
%    TO DO: why is field 'Length' needed, NCWRITESCHEMA should be able to find this out itself

    % 2D	
    s_t.dims(1) = struct('Name', dimname           ,'Length',ncdimlen.(dimname));
    s_t.dims(2) = struct('Name', 'time'            ,'Length',ncdimlen.time);

    % 3D
    s_t_k.dims(1) = struct('Name', 'Layer'         ,'Length',ncdimlen.Layer);
    s_t_k.dims(2) = struct('Name', dimname         ,'Length',ncdimlen.(dimname));
    s_t_k.dims(3) = struct('Name', 'time'          ,'Length',ncdimlen.time);

    % 3D
    s_t_ki.dims(1) = struct('Name', 'LayerInterf'  ,'Length',ncdimlen.LayerInterf);
    s_t_ki.dims(2) = struct('Name', dimname        ,'Length',ncdimlen.(dimname));
    s_t_ki.dims(3) = struct('Name', 'time'         ,'Length',ncdimlen.time);

    % 3D
    s_t_f.dims(1) = struct('Name', 'Fraction'      ,'Length',ncdimlen.Fraction);
    s_t_f.dims(2) = struct('Name', dimname         ,'Length',ncdimlen.(dimname));
    s_t_f.dims(3) = struct('Name', 'time'          ,'Length',ncdimlen.time);

    if ~isempty(vs_get_elm_def(F,'NAMTRA')) && ~isempty(OPT.crsind)
        % 2D	
        x_t.dims(1) = struct('Name', dimname2          ,'Length',ncdimlen.(dimname2));
        x_t.dims(2) = struct('Name', 'time'            ,'Length',ncdimlen.time);

        % 3D
        x_t_f.dims(1) = struct('Name', 'Fraction'      ,'Length',ncdimlen.Fraction);
        x_t_f.dims(2) = struct('Name', dimname2        ,'Length',ncdimlen.(dimname2));
        x_t_f.dims(3) = struct('Name', 'time'          ,'Length',ncdimlen.time);
    end
   
%% 3 Fill variables
    %% time

    if isempty(OPT.timezone)
        fprintf(2,'> No model timezone supplied, timezone could NOT be added to netCDF file. This will be interpreted as GMT! \n')
    end

    ifld     = 1; clear attr dims;
    attr(    1)  = struct('Name', 'standard_name', 'Value', 'time');
    attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'time');
    attr(end+1)  = struct('Name', 'units'        , 'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',OPT.timezone]);
    attr(end+1)  = struct('Name', 'axis'         , 'Value', 'T');
    attr(end+1)  = struct('Name', 'actual_range' , 'Value', [datestr(T.datenum(1),31),char(9),datestr(T.datenum(end),31)]);
    nc.Variables(ifld) = struct('Name'      , 'time', ...
                          'Datatype'  , 'double', ...
                          'Dimensions', struct('Name', 'time','Length',ncdimlen.time), ...
                          'Attributes' , attr,...
                          'FillValue'  , []);

    %% platforms/stations/observation points or trajectory and cross-sections (optional)

    if OPT.trajectory
        ifld     = ifld + 1; clear attr;
        attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_x_coordinate');
        attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'trajectory');
        attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
        attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
        attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
        attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.trajectory(:)) max(G.trajectory(:))]);
        nc.Variables(ifld) = struct('Name'      , 'Trajectory', ...
                              'Datatype'  , OPT.type, ...
                              'Dimensions', struct('Name', dimname,'Length',ncdimlen.(dimname)), ...
                              'Attributes' , attr,...
                              'FillValue'  , []);
    else
        ifld     = ifld + 1;clear attr;d3d_name = 'NAMST';
        attr(    1)  = struct('Name', 'standard_name', 'Value', 'platform_name');
        attr(end+1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
        attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
        dims(    1)  = struct('Name', 'station_name_len','Length',ncdimlen.station_name_len);
        dims(    2)  = struct('Name', dimname           ,'Length',ncdimlen.(dimname));
        nc.Variables(ifld) = struct('Name'      , 'station_name', ...
                              'Datatype'  , 'char', ...
                              'Dimensions', dims, ...
                              'Attributes' , attr,...
                              'FillValue'  , []);

        ifld     = ifld + 1;clear attr;
        attr(    1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW m index of station');
        attr(end+1)  = struct('Name', 'units'        , 'Value', '');
        attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'MNSTAT');
        attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
        attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.m(:)) max(G.m(:))]);
        nc.Variables(ifld) = struct('Name'      , 'station_m_index', ...
                              'Datatype'  , OPT.type, ...
                              'Dimensions', struct('Name', dimname,'Length',ncdimlen.(dimname)), ...
                              'Attributes' , attr,...
                              'FillValue'  , []);

        ifld     = ifld + 1;clear attr;
        attr(    1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW n index of station');
        attr(end+1)  = struct('Name', 'units'        , 'Value', '');
        attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'MNSTAT');
        attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
        attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.n(:)) max(G.n(:))]);
        nc.Variables(ifld) = struct('Name'      , 'station_n_index', ...
                              'Datatype'  , OPT.type, ...
                              'Dimensions', struct('Name', dimname,'Length',ncdimlen.(dimname)), ...
                              'Attributes' , attr,...
                              'FillValue'  , []);

        ifld     = ifld + 1;clear attr;d3d_name = 'ALFAS';
        attr(    1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
        attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
        nc.Variables(ifld) = struct('Name'      , 'station_angle', ...
                              'Datatype'  , OPT.type, ...
                              'Dimensions', struct('Name', dimname,'Length',ncdimlen.(dimname)), ...
                              'Attributes' , attr,...
                              'FillValue'  , []);

        if ~isempty(vs_get_elm_def(F,'NAMTRA')) && ~isempty(OPT.crsind)
            ifld     = ifld + 1;clear attr dims;d3d_name = 'NAMTRA';
            attr(    1)  = struct('Name', 'standard_name', 'Value', 'x_section_name');
            attr(end+1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
            attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
            dims(    2)  = struct('Name', dimname2           ,'Length',ncdimlen.(dimname2));
            dims(    1)  = struct('Name', 'x_section_name_len','Length',ncdimlen.x_section_name_len);
            nc.Variables(ifld) = struct('Name'      , 'x_section_name', ...
                                      'Datatype'  , 'char', ...
                                      'Dimensions', dims, ...
                                      'Attributes' , attr,...
                                      'FillValue'  , []);

            ifld     = ifld + 1;clear attr dims;
            attr(    1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW m indeces of cross-section');
            attr(end+1)  = struct('Name', 'units'        , 'Value', '');
            attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'MNTRA');
            attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
            attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.crsm(:)) max(G.crsm(:))]);
            dims(    2)  = struct('Name', dimname2,'Length',ncdimlen.(dimname2));
            dims(    1)  = struct('Name', 'start_end','Length',2);
            nc.Variables(ifld) = struct('Name'      , 'x_section_m_indeces', ...
                                      'Datatype'  , OPT.type, ...
                                      'Dimensions', dims, ...
                                      'Attributes' , attr,...
                                      'FillValue'  , []);

            ifld     = ifld + 1;clear attr dims;
            attr(    1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW n indeces of cross-section');
            attr(end+1)  = struct('Name', 'units'        , 'Value', '');
            attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'MNTRA');
            attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
            attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.crsn(:)) max(G.crsn(:))]);
            dims(    2)  = struct('Name', dimname2,'Length',ncdimlen.(dimname2));
            dims(    1)  = struct('Name', 'start_end','Length',2);
            nc.Variables(ifld) = struct('Name'      , 'x_section_n_indeces', ...
                                      'Datatype'  , OPT.type, ...
                                      'Dimensions', dims, ...
                                      'Attributes' , attr,...
                                      'FillValue'  , []);
        end
    end

    %% horizontal coordinates: (x,y) and (lon,lat), on centres and corners

    if any(strfind(G.coordinates,'CARTESIAN')) || ~isempty(OPT.epsg)
        ifld     = ifld + 1;clear attr
        attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_x_coordinate');
        attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'x of station');
        attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
        attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
        attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'XYSTAT');
        attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
        attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.x(:)) max(G.x(:))]);
        nc.Variables(ifld) = struct('Name'      , 'x', ...
                                  'Datatype'  , OPT.type, ...
                                  'Dimensions', struct('Name', dimname,'Length',ncdimlen.(dimname)), ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []);

        ifld     = ifld + 1;clear attr
        attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_y_coordinate');
        attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'y of station');
        attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
        attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
        attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'XYSTAT');
        attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
        attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.y(:)) max(G.y(:))]);
        nc.Variables(ifld) = struct('Name'      , 'y', ...
                                  'Datatype'  , OPT.type, ...
                                  'Dimensions', struct('Name', dimname,'Length',ncdimlen.(dimname)), ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []);
    end

    if ~any(strfind(G.coordinates,'CARTESIAN')) || ~isempty(OPT.epsg)
        ifld     = ifld + 1;clear attr
        attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
        attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Longitude of station');
        attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
        attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
        attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'XYSTAT');
        attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
        attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.lon(:)) max(G.lon(:))]);
        nc.Variables(ifld) = struct('Name'      , 'longitude', ...
                                  'Datatype'  , OPT.type, ...
                                  'Dimensions', struct('Name', dimname,'Length',ncdimlen.(dimname)), ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []);

        ifld     = ifld + 1;clear attr
        attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
        attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Latitude of station');
        attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
        attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
        attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'XYSTAT');
        attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
        attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.lat(:)) max(G.lat(:))]);
        nc.Variables(ifld) = struct('Name'      , 'latitude', ...
                                  'Datatype'  , OPT.type, ...
                                  'Dimensions', struct('Name', dimname,'Length',ncdimlen.(dimname)), ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []);
    end

    if ~isempty(vs_get_elm_def(F,'NAMTRA')) && ~isempty(OPT.crsind)
        if any(strfind(G.coordinates,'CARTESIAN')) || ~isempty(OPT.epsg)
            ifld     = ifld + 1;clear attr dims
            attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_x_coordinate');
            attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'x of cross-section');
            attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
            attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
            attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'XYTRA');
            attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
            attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.crsx(:)) max(G.crsx(:))]);
            dims(    2)  = struct('Name', dimname2,'Length',ncdimlen.(dimname2));
            dims(    1)  = struct('Name', 'start_end','Length',2);
            nc.Variables(ifld) = struct('Name'      , 'crsx', ...
                                      'Datatype'  , OPT.type, ...
                                      'Dimensions', dims, ...
                                      'Attributes' , attr,...
                                      'FillValue'  , []);

            ifld     = ifld + 1;clear attr dims
            attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_y_coordinate');
            attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'y of cross-section');
            attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
            attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
            attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'XYTRA');
            attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
            attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.y(:)) max(G.y(:))]);
            dims(    2)  = struct('Name', dimname2,'Length',ncdimlen.(dimname2));
            dims(    1)  = struct('Name', 'start_end','Length',2);
            nc.Variables(ifld) = struct('Name'      , 'crsy', ...
                                      'Datatype'  , OPT.type, ...
                                      'Dimensions', dims, ...
                                      'Attributes' , attr,...
                                      'FillValue'  , []);
        end

        if ~any(strfind(G.coordinates,'CARTESIAN')) || ~isempty(OPT.epsg)
            ifld     = ifld + 1;clear attr dims
            attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
            attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Longitude of cross-section');
            attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
            attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
            attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'XYTRA');
            attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
            attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.crslon(:)) max(G.crslon(:))]);
            dims(    2)  = struct('Name', dimname2,'Length',ncdimlen.(dimname2));
            dims(    1)  = struct('Name', 'start_end','Length',2);
            nc.Variables(ifld) = struct('Name'      , 'crslongitude', ...
                                      'Datatype'  , OPT.type, ...
                                      'Dimensions', dims, ...
                                      'Attributes' , attr,...
                                      'FillValue'  , []);

            ifld     = ifld + 1;clear attr dims
            attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
            attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Latitude of cross-section');
            attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
            attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
            attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'XYTRA');
            attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
            attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.crslat(:)) max(G.crslat(:))]);
            dims(    2)  = struct('Name', dimname2,'Length',ncdimlen.(dimname2));
            dims(    1)  = struct('Name', 'start_end','Length',2);
            nc.Variables(ifld) = struct('Name'      , 'crslatitude', ...
                                      'Datatype'  , OPT.type, ...
                                      'Dimensions', dims, ...
                                      'Attributes' , attr,...
                                      'FillValue'  , []);
        end
    end

    %% vertical coordinates

    if strmatch('SIGMA-MODEL', G.layer_model)
        ifld     = ifld + 1;clear attr;
        attr(    1)  = struct('Name', 'long_name'    , 'Value', 'sigma at layer midpoints');
        attr(end+1)  = struct('Name', 'standard_name', 'Value', 'ocean_sigma_coordinate');
        attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
        attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
        attr(end+1)  = struct('Name', 'formula_terms', 'Value', 'sigma: Layer eta: waterlevel depth: depth'); % requires depth to be positive !!
        attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The surface layer has index k=1 and is sigma=0, the bottom layer has index kmax and is sigma=-1.');
        attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'his-const:KMAX his-const:LAYER_MODEL his-const:THICK');
        nc.Variables(ifld) = struct('Name'      , 'Layer', ...
                                  'Datatype'  , OPT.type, ...
                                  'Dimensions', struct('Name', 'Layer','Length',ncdimlen.Layer), ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []);

        ifld     = ifld + 1;clear attr;
        attr(    1)  = struct('Name', 'long_name'    , 'Value', 'sigma at layer interfaces');
        attr(end+1)  = struct('Name', 'standard_name', 'Value', 'ocean_sigma_coordinate');
        attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
        attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
        attr(end+1)  = struct('Name', 'formula_terms', 'Value', 'sigma: LayerInterf eta: waterlevel depth: depth'); % requires depth to be positive !!
        attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The surface layer has index k=1 and is sigma=0, the bottom layer has index kmax and is sigma=-1.');
        attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'his-const:KMAX his-const:LAYER_MODEL his-const:THICK');
        nc.Variables(ifld) = struct('Name'      , 'LayerInterf', ...
                                  'Datatype'  , OPT.type, ...
                                  'Dimensions', struct('Name', 'LayerInterf','Length',ncdimlen.LayerInterf), ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []);
    elseif strmatch('Z-MODEL', G.layer_model)
        ifld     = ifld + 1;clear attr;
        attr(    1)  = struct('Name', 'long_name'    , 'Value', 'z at layer midpoints');
        attr(end+1)  = struct('Name', 'standard_name', 'Value', 'altitude');
        attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
        attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
        attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
        attr(end+1)  = struct('Name', 'formula_terms', 'Value', 'sigma: Layer eta: waterlevel depth: depth'); % requires depth to be positive !!
        attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The bottom layer has index k=1 and is the bottom depth, the surface layer has index kmax and is z=free water surface.');
        attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'his-const:KMAX his-const:LAYER_MODEL his-const:ZK');
        nc.Variables(ifld) = struct('Name'      , 'Layer', ...
                                  'Datatype'  , OPT.type, ...
                                  'Dimensions', struct('Name', 'Layer','Length',ncdimlen.Layer), ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []);

        ifld     = ifld + 1;clear attr;
        attr(    1)  = struct('Name', 'long_name'    , 'Value', 'z at layer interfaces');
        attr(end+1)  = struct('Name', 'standard_name', 'Value', 'altitude');
        attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
        attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
        attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
        attr(end+1)  = struct('Name', 'formula_terms', 'Value', 'sigma: LayerInterf eta: waterlevel depth: depth'); % requires depth to be positive !!
        attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The bottom layer has index k=1 and is the bottom depth, the surface layer has index kmax and is z=free water surface.');
        attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'his-const:KMAX his-const:LAYER_MODEL his-const:ZK');
        nc.Variables(ifld) = struct('Name'      , 'LayerInterf', ...
                                  'Datatype'  , OPT.type, ...
                                  'Dimensions', struct('Name', 'LayerInterf','Length',ncdimlen.LayerInterf), ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []);
    end % z/sigma

    %% bathymetry

    ifld     = ifld + 1;clear attr; d3d_name = 'DPS';
    attr(    1)  = struct('Name', 'standard_name', 'Value', 'altitude');
    attr(end+1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
    attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
    attr(end+1)  = struct('Name', 'positive'     , 'Value', 'down');
    attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
    attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
    attr(end+1)  = struct('Name', 'comment'      , 'Value', '');
    nc.Variables(ifld) = struct('Name'      , 'depth', ...
                              'Datatype'  , OPT.type, ...
                              'Dimensions', struct('Name', dimname,'Length',ncdimlen.(dimname)), ...
                              'Attributes' , attr,...
                              'FillValue'  , []);
          
    %% Create (primary) variables: momentum and mass conservation

    ifld     = ifld + 1;clear attr; d3d_name = 'ZWL';
    attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_surface_elevation');
    attr(end+1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
    attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
    attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
    attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
    attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
    attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
    attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
    nc.Variables(ifld) = struct('Name'      , 'waterlevel', ...
                              'Datatype'  , OPT.type, ...
                              'Dimensions', s_t.dims, ...
                              'Attributes' , attr,...
                              'FillValue'  , []);

    ifld     = ifld + 1;clear attr; d3d_name = 'ZKFS';
    attr(    1)  = struct('Name', 'standard_name', 'Value', '');
    attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'active');
    attr(end+1)  = struct('Name', 'units'        , 'Value', '1');
    attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
    attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
    attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
    attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
    attr(end+1)  = struct('Name', 'flag_values'  , 'Value', [0 1]);
    attr(end+1)  = struct('Name', 'flag_meanings', 'Value', 'inactive active ');
    nc.Variables(ifld) = struct('Name'      , 'mask', ...
                              'Datatype'  , OPT.type, ...
                              'Dimensions', s_t.dims, ...
                              'Attributes' , attr,...
                              'FillValue'  , []);

    ifld     = ifld + 1;clear attr;d3d_name = 'ZCURU';
    if (~any(strfind(G.coordinates,'CART'))) % CARTESIAN, CARTHESIAN (old bug)
        attr(    1)  = struct('Name', 'standard_name', 'Value', 'eastward_sea_water_velocity'); % surface_geostrophic_sea_water_x_velocity_assuming_sea_level_for_geoid
        attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'velocity, lon-component');
    else
        attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_water_x_velocity'); % surface_geostrophic_sea_water_x_velocity_assuming_sea_level_for_geoid
        attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'velocity, x-component');
    end
    attr(end+1)  = struct('Name', 'units'        , 'Value', 'm/s');
    attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
    attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
    attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
    attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.u_x = [Inf -Inf];
    nc.Variables(ifld) = struct('Name'      , 'u_x', ...
                              'Datatype'  , OPT.type, ...
                              'Dimensions', s_t_k.dims, ...
                              'Attributes' , attr,...
                              'FillValue'  , []);
      
    ifld     = ifld + 1;clear attr;d3d_name = 'ZCURV';
    if (~any(strfind(G.coordinates,'CART'))) % CARTESIAN, CARTHESIAN (old bug)
        attr(    1)  = struct('Name', 'standard_name', 'Value', 'northward_sea_water_velocity'); % surface_geostrophic_sea_water_y_velocity_assuming_sea_level_for_geoid
        attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'velocity, lat-component');
    else 
        attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_water_y_velocity'); % surface_geostrophic_sea_water_y_velocity_assuming_sea_level_for_geoid
        attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'velocity, y-component');
    end
    attr(end+1)  = struct('Name', 'units'        , 'Value', 'm/s');
    attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
    attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
    attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
    attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.u_y = [Inf -Inf];
    nc.Variables(ifld) = struct('Name'      , 'u_y', ...
                              'Datatype'  , OPT.type, ...
                              'Dimensions', s_t_k.dims, ...
                              'Attributes' , attr,...
                              'FillValue'  , []);

    ifld     = ifld + 1;clear attr;d3d_name = 'ZCURW';
    attr(    1)  = struct('Name', 'standard_name', 'Value', 'upward_sea_water_velocity');
    attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'velocity, z-component');
    attr(end+1)  = struct('Name', 'units'        , 'Value', 'm/s');
    attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
    attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
    attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
    attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
    attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.u_z = [Inf -Inf];
    nc.Variables(ifld) = struct('Name'      , 'u_z', ...
                              'Datatype'  , OPT.type, ...
                              'Dimensions', s_t_k.dims, ...
                              'Attributes' , attr,...
                              'FillValue'  , []);
                              
    if ~isempty(vs_get_elm_def(F,'NAMTRA')) && ~isempty(OPT.crsind)
        ifld     = ifld + 1;clear attr;d3d_name = 'CTR';
        attr(    1)  = struct('Name', 'standard_name', 'Value', '');
        attr(end+1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
        attr(end+1)  = struct('Name', 'units'        , 'Value', 'm3/s');
        attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
        attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
        attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
        attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.Q = [Inf -Inf];
        nc.Variables(ifld) = struct('Name'      , 'Q', ...
                                  'Datatype'  , OPT.type, ...
                                  'Dimensions', x_t.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []);

        ifld     = ifld + 1;clear attr;d3d_name = 'FLTR';
        attr(    1)  = struct('Name', 'standard_name', 'Value', '');
        attr(end+1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
        attr(end+1)  = struct('Name', 'units'        , 'Value', 'm3');
        attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
        attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
        attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
        attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.CQ = [Inf -Inf];
        nc.Variables(ifld) = struct('Name'      , 'CQ', ...
                                  'Datatype'  , OPT.type, ...
                                  'Dimensions', x_t.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []);
    end
       
    % bottom shear stresses

    ifld     = ifld + 1;clear attr; d3d_name = 'ZTAUKS';
    if (~any(strfind(G.coordinates,'CART'))) % CARTESIAN, CARTHESIAN (old bug)
        attr(    1)  = struct('Name', 'standard_name', 'Value', 'surface_downward_northward_stress');
    else
        attr(    1)  = struct('Name', 'standard_name', 'Value', 'surface_downward_x_stress');
    end      
    attr(end+1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
    attr(end+1)  = struct('Name', 'units'        , 'Value', 'N m-2');
    attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
    attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
    attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
    attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.tau_x = [Inf -Inf];
    attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The bed shear stresses are in real world directions x and y');
    nc.Variables(ifld) = struct('Name'      , 'tau_x', ...
                              'Datatype'  , OPT.type, ...
                              'Dimensions', s_t.dims, ...
                              'Attributes' , attr,...
                              'FillValue'  , []);

    ifld     = ifld + 1;clear attr; d3d_name = 'ZTAUET';
    if (~any(strfind(G.coordinates,'CART'))) % CARTESIAN, CARTHESIAN (old bug)
        attr(    1)  = struct('Name', 'standard_name', 'Value', 'surface_downward_eastward_stress');
    else
        attr(    1)  = struct('Name', 'standard_name', 'Value', 'surface_downward_y_stress');
    end
    attr(end+1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
    attr(end+1)  = struct('Name', 'units'        , 'Value', 'N m-2');
    attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
    attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
    attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
    attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.tau_y = [Inf -Inf];
    attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The bed shear stresses are in real world directions x and y');
    nc.Variables(ifld) = struct('Name'      , 'tau_y', ...
                              'Datatype'  , OPT.type, ...
                              'Dimensions', s_t.dims, ...
                              'Attributes' , attr,...
                              'FillValue'  , []);

    % density: temperature + salinity
 
    d3d_name = 'ZRHO';
    if ~isempty(vs_get_elm_def(F,d3d_name))
        ifld     = ifld + 1;clear attr;
        attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_water_density');
        attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Density in station');
        attr(end+1)  = struct('Name', 'units'        , 'Value', 'kg/m3');
        attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
        attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
        attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
        attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.density = [Inf -Inf];
        nc.Variables(ifld) = struct('Name'      , 'density', ...
                                  'Datatype'  , OPT.type, ...
                                  'Dimensions', s_t_k.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []);
    end
 
    d3d_name = 'GRO';
    if ~isempty(strmatch('salinity',fieldnames(I)))
        ifld     = ifld + 1;clear attr;
        attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_water_salinity');
        attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Salinity in station');
        attr(end+1)  = struct('Name', 'units'        , 'Value', 'psu');
        attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
        attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
        attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
        attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.salinity = [Inf -Inf];
        nc.Variables(ifld) = struct('Name'      , 'salinity', ...
                                  'Datatype'  , OPT.type, ...
                                  'Dimensions', s_t_k.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []);
    end

    if ~isempty(strmatch('temperature',fieldnames(I)))
        ifld     = ifld + 1;clear attr;
        attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_water_temperature');
        attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Temperature in station');
        attr(end+1)  = struct('Name', 'units'        , 'Value', 'degree_Celsius');
        attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
        attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
        attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
        attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.temperature = [Inf -Inf];
        nc.Variables(ifld) = struct('Name'      , 'temperature', ...
                                  'Datatype'  , OPT.type, ...
                                  'Dimensions', s_t_k.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []);
    end

   % sediment concentration(s) 
    if ~isempty(strmatch('sediment',fieldnames(I)))
        for jj=1:G.lsed
            ifld     = ifld + 1;clear attr;
            attr(    1)  = struct('Name', 'standard_name', 'Value', '');
            attr(end+1)  = struct('Name', 'long_name'    , 'Value',  ['Concentration of ' G.namsed(jj,:) ' per layer in station']);
            attr(end+1)  = struct('Name', 'units'        , 'Value', 'kg/m3');
            attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
            attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
            attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
            attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.(G.namsed(jj,:)) = [Inf -Inf];
            nc.Variables(ifld) = struct('Name'      , G.namsed(jj,:), ...
                                      'Datatype'  , OPT.type, ...
                                      'Dimensions', s_t_k.dims, ...
                                      'Attributes' , attr,...
                                      'FillValue'  , []);
        end
    end

    % turbulence

    d3d_name = 'ZTUR';
    if ~isempty(vs_get_elm_def(F,d3d_name))
        ifld     = ifld + 1;clear attr
        attr(    1)  = struct('Name', 'standard_name', 'Value', 'specific_kinetic_energy_of_sea_water'); %?
        attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Turbulent kinetic energy in station'); % not in NEFIS file
        attr(end+1)  = struct('Name', 'units'        , 'Value', 'm2/s2'); % not in NEFIS file 
        attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
        attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
        attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
        attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.tke = [Inf -Inf];
        nc.Variables(ifld) = struct('Name'      , 'tke', ...
                                  'Datatype'  , OPT.type, ...
                                  'Dimensions', s_t_ki.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []);

        ifld     = ifld + 1;clear attr
        attr(    1)  = struct('Name', 'standard_name', 'Value', 'ocean_kinetic_energy_dissipation_per_unit_area_due_to_vertical_friction'); %?
        attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Turbulent dissipation in station');    % not in NEFIS file
        attr(end+1)  = struct('Name', 'units'        , 'Value', 'm2/s3'); % 'W m-2'); % not in NEFIS file
        attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
        attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
        attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
        attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.eps = [Inf -Inf];
        nc.Variables(ifld) = struct('Name'      , 'eps', ...
                                  'Datatype'  , OPT.type, ...
                                  'Dimensions', s_t_ki.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []);
    end
      
    d3d_name = 'ZVICWW';
    ifld     = ifld + 1;clear attr
    attr(    1)  = struct('Name', 'standard_name', 'Value', '');
    attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Vertical eddy viscosity-3D');
    attr(end+1)  = struct('Name', 'units'        , 'Value', 'm^2/s');
    attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinatesLayerInterf);
    attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
    attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN)); % this initializes at NaN rather than 9.9692e36
    attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.viscosity_z = [Inf -Inf];
    nc.Variables(ifld) = struct('Name'      , 'viscosity_z', ...
                              'Datatype'  , OPT.type, ...
                              'Dimensions', s_t_ki.dims, ...
                              'Attributes' , attr,...
                              'FillValue'  , []);

    d3d_name = 'ZDICWW';
    ifld     = ifld + 1;clear attr
    attr(    1)  = struct('Name', 'standard_name', 'Value', '');
    attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Vertical eddy diffusivity-3D');
    attr(end+1)  = struct('Name', 'units'        , 'Value', 'm^2/s');
    attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinatesLayerInterf);
    attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
    attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN)); % this initializes at NaN rather than 9.9692e36
    attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.diffusivity_z = [Inf -Inf];
    nc.Variables(ifld) = struct('Name'      , 'diffusivity_z', ...
                              'Datatype'  , OPT.type, ...
                              'Dimensions', s_t_ki.dims, ...
                              'Attributes' , attr,...
                              'FillValue'  , []);

    d3d_name = 'ZRICH';
    ifld     = ifld + 1;clear attr
    attr(    1)  = struct('Name', 'standard_name', 'Value', '');
    attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Richardson number');
    attr(end+1)  = struct('Name', 'units'        , 'Value', '-');
    attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
    attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
    attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN)); % this initializes at NaN rather than 9.9692e36
    attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.Ri = [Inf -Inf];
    nc.Variables(ifld) = struct('Name'      , 'Ri', ...
                              'Datatype'  , OPT.type, ...
                              'Dimensions', s_t_ki.dims, ...
                              'Attributes' , attr,...
                              'FillValue'  , []);

    % sediment mass
    if ~isempty(strmatch('sediment',fieldnames(I)))  
        d3d_name = 'ZDPS';
        ifld     = ifld + 1;clear attr
        attr(    1)  = struct('Name', 'standard_name', 'Value', '');
        attr(end+1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
        attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
        attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
        attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
        attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN)); % this initializes at NaN rather than 9.9692e36
        attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.morphological_depth = [Inf -Inf];
        nc.Variables(ifld) = struct('Name'      , 'morphological_depth', ...
                                  'Datatype'  , OPT.type, ...
                                  'Dimensions', s_t.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []);

        d3d_name = 'ZBDSED';
        ifld     = ifld + 1;clear attr
        attr(    1)  = struct('Name', 'standard_name', 'Value', '');
        attr(end+1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
        attr(end+1)  = struct('Name', 'units'        , 'Value', 'kg/m2');
        attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
        attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
        attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN)); % this initializes at NaN rather than 9.9692e36
        attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.available_mass_of_sediment = [Inf -Inf];
        nc.Variables(ifld) = struct('Name'      , 'available_mass_of_sediment', ...
                                  'Datatype'  , OPT.type, ...
                                  'Dimensions', s_t_f.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []);
    
        if ~isempty(vs_get_elm_def(F,'NAMTRA')) && ~isempty(OPT.crsind)
            d3d_name = 'SBTR';
            ifld     = ifld + 1;clear attr
            attr(    1)  = struct('Name', 'standard_name', 'Value', '');
            attr(end+1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
            attr(end+1)  = struct('Name', 'units'        , 'Value', 'm3/s');
            attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
            attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
            attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN)); % this initializes at NaN rather than 9.9692e36
            attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.bed_load_transport = [Inf -Inf];
            nc.Variables(ifld) = struct('Name'      , 'bed_load_transport', ...
                                      'Datatype'  , OPT.type, ...
                                      'Dimensions', x_t_f.dims, ...
                                      'Attributes' , attr,...
                                      'FillValue'  , []);

            d3d_name = 'SBTRC';
            ifld     = ifld + 1;clear attr
            attr(    1)  = struct('Name', 'standard_name', 'Value', '');
            attr(end+1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
            attr(end+1)  = struct('Name', 'units'        , 'Value', 'm3');
            attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
            attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
            attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN)); % this initializes at NaN rather than 9.9692e36
            attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.cumulative_bed_load_transport = [Inf -Inf];
            nc.Variables(ifld) = struct('Name'      , 'cumulative_bed_load_transport', ...
                                      'Datatype'  , OPT.type, ...
                                      'Dimensions', x_t_f.dims, ...
                                      'Attributes' , attr,...
                                      'FillValue'  , []);

            d3d_name = 'SSTR';
            ifld     = ifld + 1;clear attr
            attr(    1)  = struct('Name', 'standard_name', 'Value', '');
            attr(end+1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
            attr(end+1)  = struct('Name', 'units'        , 'Value', 'm3/s');
            attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
            attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
            attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN)); % this initializes at NaN rather than 9.9692e36
            attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.suspended_load_transport = [Inf -Inf];
            nc.Variables(ifld) = struct('Name'      , 'suspended_load_transport', ...
                                      'Datatype'  , OPT.type, ...
                                      'Dimensions', x_t_f.dims, ...
                                      'Attributes' , attr,...
                                      'FillValue'  , []);

            d3d_name = 'SSTRC';
            ifld     = ifld + 1;clear attr
            attr(    1)  = struct('Name', 'standard_name', 'Value', '');
            attr(end+1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
            attr(end+1)  = struct('Name', 'units'        , 'Value', 'm3');
            attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
            attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
            attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN)); % this initializes at NaN rather than 9.9692e36
            attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.cumulative_suspended_load_transport = [Inf -Inf];
            nc.Variables(ifld) = struct('Name'      , 'cumulative_suspended_load_transport', ...
                                      'Datatype'  , OPT.type, ...
                                      'Dimensions', x_t_f.dims, ...
                                      'Attributes' , attr,...
                                      'FillValue'  , []);                       
        end
    end
      
%% 4 Create netCDF file
    
    if OPT.debug
        ls(ncfile)
        var2evalstr(nc)
    end

    try;delete(ncfile);end
    disp(['vs_trih2nc: NCWRITESCHEMA: creating netCDF file: ',ncfile])
    ncwriteschema(ncfile, nc);			        
    disp(['vs_trih2nc: NCWRITE: filling  netCDF file: ',ncfile])

    if OPT.debug
        fid = fopen([filepathstrname(ncfile),'.cdl'],'w');
        nc_dump(ncfile,fid);
        fclose(fid);
    end

%% 5 Fill variables
    
    if OPT.trajectory
        disp('Writing trajectory coordinates...')
        ncwrite(ncfile, 'Trajectory'          , G.trajectory);
    else
        disp('Writing stations info...')
        ncwrite(ncfile, 'station_name'        , G.name');
        ncwrite(ncfile, 'station_angle'       , G.angle);
        ncwrite(ncfile, 'station_m_index'     , G.m);
        ncwrite(ncfile, 'station_n_index'     , G.n);
    end

    if ~isempty(vs_get_elm_def(F,'NAMTRA')) && ~isempty(OPT.crsind)
        disp('Writing cross-sections info...')
        ncwrite(ncfile, 'x_section_name'        , G.crsname');
        ncwrite(ncfile, 'x_section_m_indeces'     , G.crsm);
        ncwrite(ncfile, 'x_section_n_indeces'     , G.crsn);
    end

    if  any(strfind(G.coordinates,'CARTESIAN')) || ~isempty(OPT.epsg)
        ncwrite(ncfile, 'x', G.x);
        ncwrite(ncfile, 'y', G.y);
        if ~isempty(vs_get_elm_def(F,'NAMTRA')) && ~isempty(OPT.crsind)
            ncwrite(ncfile, 'crsx', G.crsx);
            ncwrite(ncfile, 'crsy', G.crsy);
        end
    end
    
    if ~any(strfind(G.coordinates,'CARTESIAN')) || ~isempty(OPT.epsg)
        ncwrite(ncfile, 'longitude'  , G.lon);
        ncwrite(ncfile, 'latitude'   , G.lat);
        if ~isempty(vs_get_elm_def(F,'NAMTRA')) && ~isempty(OPT.crsind)
            ncwrite(ncfile, 'crslongitude'  , G.crslon);
            ncwrite(ncfile, 'crslatitude'   , G.crslat);
        end
    end
      
    disp('Writing time...')
    ncwrite(ncfile, 'time'         , T.datenum - OPT.refdatenum);   

    disp('Writing layers...')
    if strmatch('SIGMA-MODEL', G.layer_model)
        matrix = vs_let(F,'his-const','THICK','quiet');
        [sigma,sigmaInterf] = d3d_sigma(matrix); % [0 .. 1]
        ncwrite   (ncfile,'Layer'         ,sigma-1);
        ncwriteatt(ncfile,'Layer'         ,'actual_range',[min(sigma(:)-1) max(sigma(:)-1)]);

        ncwrite   (ncfile,'LayerInterf'   ,sigmaInterf-1);
        ncwriteatt(ncfile,'LayerInterf'   ,'actual_range',[min(sigmaInterf(:)-1) max(sigmaInterf(:)-1)]); % [-1 0]
    elseif strmatch('Z-MODEL', G.layer_model)
        Layer = corner2center1(G.ZK);
        ncwrite   (ncfile,'Layer'         ,Layer);
        ncwriteatt(ncfile,'Layer'         ,'actual_range',[min(Layer(:)) max(Layer(:))]);

        ncwrite   (ncfile,'LayerInterf'   ,G.ZK);
        ncwriteatt(ncfile,'LayerInterf'   ,'actual_range',[min(G.ZK(:)) max(G.ZK(:))]);
    end

    disp('Writing bathymetry...')
    matrix = vs_let(F,'his-const','DPS',{OPT.ind},OPT.quiet);
    ncwrite   (ncfile,'depth',matrix); 
    ncwriteatt(ncfile,'depth','actual_range',[min(matrix(:)) max(matrix(:))]);

    disp('Writing water levels...')
    matrix = vs_let(F,'his-series','ZWL',{OPT.ind},OPT.quiet);
    ncwrite(ncfile,'waterlevel',permute(matrix,[2 1]));
    nc_attput(ncfile,'waterlevel','actual_range',[min(matrix(:)) max(matrix(:))]);

    disp('Writing active/inactive wl points...')
    matrix = vs_let(F,'his-series','ZKFS',{OPT.ind},OPT.quiet);
    ncwrite(ncfile,'mask',permute(matrix,[2 1]));
    nc_attput(ncfile,'mask','actual_range',[min(matrix(:)) max(matrix(:))]);

    if ~isempty(vs_get_elm_def(F,'NAMTRA')) && ~isempty(OPT.crsind)
        disp('Writing discharge cross-sections...')
        matrix = vs_let(F,'his-series','CTR',{OPT.crsind},OPT.quiet);
        ncwrite(ncfile,'Q',permute(matrix,[2 1]));
        nc_attput(ncfile,'Q','actual_range',[min(matrix(:)) max(matrix(:))]);

        matrix = vs_let(F,'his-series','FLTR',{OPT.crsind},OPT.quiet);
        ncwrite(ncfile,'CQ',permute(matrix,[2 1]));
        R.CQ = [min(R.CQ(1),min(matrix(:))) max(R.CQ(2),max(matrix(:)))];
        nc_attput(ncfile,'CQ','actual_range',[min(matrix(:)) max(matrix(:))]);
    end
    
    disp('Writing flow velocities...')
    if OPT.stride    
        for k=1:G.kmax

            matrix = vs_let(F,'his-series','ZCURU',{OPT.ind,k},OPT.quiet);
            ncwrite(ncfile,'u_x',permute(matrix,[3 2 1]),[k 1 1]);
            R.u_x(1) = min(R.u_x(1),min(matrix(:)));
            R.u_x(2) = max(R.u_x(2),max(matrix(:)));

            matrix = vs_let(F,'his-series','ZCURV',{OPT.ind,k},OPT.quiet);
            ncwrite(ncfile,'u_y',permute(matrix,[3 2 1]),[k 1 1]);
            R.u_y(1) = min(R.u_y(1),min(matrix(:)));
            R.u_y(2) = max(R.u_y(2),max(matrix(:)));

            matrix = vs_let(F,'his-series','ZCURW',{OPT.ind,k},OPT.quiet);
            ncwrite(ncfile,'u_z',permute(matrix,[3 2 1]),[k 1 1]);
            R.u_z(1) = min(R.u_z(1),min(matrix(:)));
            R.u_z(2) = max(R.u_z(2),max(matrix(:)));
        end
    else
        matrix = vs_let(F,'his-series','ZCURU',{OPT.ind,0},OPT.quiet);
        ncwrite(ncfile,'u_x',permute(matrix,[3 2 1]));
        R.u_x = [min(matrix(:)) max(matrix(:))];

        matrix = vs_let(F,'his-series','ZCURV',{OPT.ind,0},OPT.quiet);
        ncwrite(ncfile,'u_y',permute(matrix,[3 2 1]));
        R.u_y = [min(matrix(:)) max(matrix(:))];

        matrix = vs_let(F,'his-series','ZCURW',{OPT.ind,0},OPT.quiet);
        ncwrite(ncfile,'u_z',permute(matrix,[3 2 1]));
        R.u_z = [min(matrix(:)) max(matrix(:))];
    end
      
    disp('Writing bed shear stresses...')
    matrix = vs_let(F,'his-series','ZTAUKS',{OPT.ind},OPT.quiet);
    ncwrite   (ncfile,'tau_x',permute(matrix,[2 1]));
    ncwriteatt(ncfile,'tau_x','actual_range',[min(matrix(:)) max(matrix(:))]);
    R.tau_x = [min(matrix(:)) max(matrix(:))];

    matrix = vs_let(F,'his-series','ZTAUET',{OPT.ind},OPT.quiet);
    ncwrite   (ncfile,'tau_y',permute(matrix,[2 1]));
    R.tau_y = [min(matrix(:)) max(matrix(:))];

    disp('Writing density...')
    if OPT.stride
        for k=1:G.kmax
            matrix = vs_let(F,'his-series','ZRHO',{OPT.ind,k},OPT.quiet);
            ncwrite(ncfile,'density',permute(matrix,[3 2 1]),[k 1 1]);
            R.density(1) = min(R.density(1),min(matrix(:)));
            R.density(2) = max(R.density(2),max(matrix(:)));
        end
    else
        matrix = vs_let(F,'his-series','ZRHO',{OPT.ind,0},OPT.quiet);
        ncwrite(ncfile,'density',permute(matrix,[3 2 1]));
        R.density = [min(R.density(1),min(matrix(:))) max(R.density(2),max(matrix(:)))];
    end   

    if isfield(I,'salinity')  
        disp('Writing salinity...')
        if OPT.stride
            for k=1:G.kmax
                matrix = vs_let(F,'his-series','GRO',{OPT.ind,k,I.salinity.index},OPT.quiet);
                ncwrite(ncfile,'salinity',permute(matrix,[3 2 1]),[k 1 1]);
                R.salinity(1) = min(R.salinity(1),min(matrix(:)));
                R.salinity(2) = max(R.salinity(2),max(matrix(:)));
            end
        else
            matrix = vs_let(F,'his-series','GRO',{OPT.ind,0,I.salinity.index},OPT.quiet);
            ncwrite(ncfile,'salinity',permute(matrix,[3 2 1]));
            R.salinity = [min(R.salinity(1),min(matrix(:))) max(R.salinity(2),max(matrix(:)))];
        end   
    end

    if isfield(I,'temperature')
        disp('Writing temperature...')
        if OPT.stride
            for k=1:G.kmax
                matrix = vs_let(F,'his-series','GRO',{OPT.ind,k,I.temperature.index},OPT.quiet);
                ncwrite(ncfile,'temperature',permute(matrix,[3 2 1]),[k 1 1]);
                R.temperature(1) = min(R.temperature(1),min(matrix(:)));
                R.temperature(2) = max(R.temperature(2),max(matrix(:)));
            end
        else
            matrix = vs_let(F,'his-series','GRO',{OPT.ind,0,I.temperature.index},OPT.quiet);
            ncwrite(ncfile,'temperature',permute(matrix,[3 2 1]));
            R.temperature = [min(R.temperature(1),min(matrix(:))) max(R.temperature(2),max(matrix(:)))];
        end   
    end
  
    if ~isempty(strmatch('sediment',fieldnames(I)))
        disp('Writing sediment concentrations...')
        for jj=1:G.lsed
            if OPT.stride
                for k=1:G.kmax
                matrix = vs_let(F,'his-series','GRO',{OPT.ind,k,G.sedind(jj)},OPT.quiet);
                ncwrite(ncfile,G.namsed(jj,:),permute(matrix,[3 2 1]),[k 1 1]);
                R.(G.namsed(jj,:))(1) = min(R.(G.namsed(jj,:))(1),min(matrix(:)));
                R.(G.namsed(jj,:))(2) = max(R.(G.namsed(jj,:))(2),max(matrix(:)));
                end
            else
                matrix = vs_let(F,'his-series','GRO',{OPT.ind,0,G.sedind(jj)},OPT.quiet);
                ncwrite(ncfile,G.namsed(jj,:),permute(matrix,[3 2 1]));
                R.(G.namsed(jj,:)) = [min(R.(G.namsed(jj,:))(1),min(matrix(:))) max(R.(G.namsed(jj,:))(2),max(matrix(:)))];
            end   
        end
    end

    if isfield(I,'turbulent_energy')  
        disp('Writing turbulent energy...')
        if OPT.stride
            for k=1:G.kmax+1
                matrix = vs_let(F,'his-series','ZTUR',{OPT.ind,k,I.turbulent_energy.index},OPT.quiet);
                ncwrite(ncfile,'tke',permute(matrix,[3 2 1]),[k 1 1]);
                R.tke(1) = min(R.tke(1),min(matrix(:)));
                R.tke(2) = max(R.tke(2),max(matrix(:)));
            end
        else
            matrix = vs_let(F,'his-series','ZTUR',{OPT.ind,0,I.turbulent_energy.index},OPT.quiet);
            ncwrite(ncfile,'tke',permute(matrix,[3 2 1]));
            R.tke = [min(R.tke(1),min(matrix(:))) max(R.tke(2),max(matrix(:)))];
        end   
    end

    if isfield(I,'energy_dissipation')  
        disp('Writing energy dissipation...')
        if OPT.stride
            for k=1:G.kmax+1
                matrix = vs_let(F,'his-series','ZTUR',{OPT.ind,k,I.energy_dissipation.index},OPT.quiet);
                ncwrite(ncfile,'eps',permute(matrix,[3 2 1]),[k 1 1]);
                R.eps(1) = min(R.eps(1),min(matrix(:)));
                R.eps(2) = max(R.eps(2),max(matrix(:)));
            end
        else
            matrix = vs_let(F,'his-series','ZTUR',{OPT.ind,0,I.energy_dissipation.index},OPT.quiet);
            ncwrite(ncfile,'eps',permute(matrix,[3 2 1]));
            R.eps = [min(R.eps(1),min(matrix(:))) max(R.eps(2),max(matrix(:)))];
        end   
    end
    
    disp('Writing viscosity...')
    if OPT.stride    
        for k=1:G.kmax+1
            matrix = vs_let(F,'his-series','ZVICWW',{OPT.ind,k},OPT.quiet);
            ncwrite(ncfile,'viscosity_z',permute(matrix,[3 2 1]),[k 1 1]);
            R.viscosity_z(1) = min(R.viscosity_z(1),min(matrix(:)));
            R.viscosity_z(2) = max(R.viscosity_z(2),max(matrix(:)));
        end
    else
        matrix = vs_let(F,'his-series','ZVICWW',{OPT.ind,0},OPT.quiet);
        ncwrite(ncfile,'viscosity_z',permute(matrix,[3 2 1]));
        R.viscosity_z = [min(R.viscosity_z(1),min(matrix(:))) max(R.viscosity_z(2),max(matrix(:)))];
    end 
    
    disp('Writing diffusivity...')
    if OPT.stride    
        for k=1:G.kmax+1
            matrix = vs_let(F,'his-series','ZDICWW',{OPT.ind,k},OPT.quiet);
            ncwrite(ncfile,'diffusivity_z',permute(matrix,[3 2 1]),[k 1 1]);
            R.diffusivity_z(1) = min(R.diffusivity_z(1),min(matrix(:)));
            R.diffusivity_z(2) = max(R.diffusivity_z(2),max(matrix(:)));
        end
    else
        matrix = vs_let(F,'his-series','ZDICWW',{OPT.ind,0},OPT.quiet);
        ncwrite(ncfile,'diffusivity_z',permute(matrix,[3 2 1]));
        R.diffusivity_z = [min(R.diffusivity_z(1),min(matrix(:))) max(R.diffusivity_z(2),max(matrix(:)))];
    end
    
    disp('Writing Richardson number...')
    if OPT.stride    
        for k=1:G.kmax+1
            matrix = vs_let(F,'his-series','ZRICH',{OPT.ind,k},OPT.quiet);
            ncwrite(ncfile,'Ri',permute(matrix,[3 2 1]),[k 1 1]);
            R.Ri(1) = min(R.Ri(1),min(matrix(:)));
            R.Ri(2) = max(R.Ri(2),max(matrix(:)));
        end
    else
        matrix = vs_let(F,'his-series','ZRICH',{OPT.ind,0},OPT.quiet);
        ncwrite(ncfile,'Ri',permute(matrix,[3 2 1]));
        R.Ri = [min(R.Ri(1),min(matrix(:))) max(R.Ri(2),max(matrix(:)))];
    end
      
    if ~isempty(strmatch('sediment',fieldnames(I)))

        disp('Writing bed level timeseries...')
        matrix = vs_let(F,'his-sed-series','ZDPS',{OPT.ind},OPT.quiet);
        ncwrite(ncfile,'morphological_depth',permute(matrix,[2 1]));
        R.morphological_depth = [min(R.morphological_depth(1),min(matrix(:))) max(R.morphological_depth(2),max(matrix(:)))];

        disp('Writing available mass of sediment...')
        matrix = vs_let(F,'his-sed-series','ZBDSED',{OPT.ind,0},OPT.quiet);
        ncwrite(ncfile,'available_mass_of_sediment',permute(matrix,[3 2 1]));
        R.available_mass_of_sediment = [min(R.available_mass_of_sediment(1),min(matrix(:))) max(R.available_mass_of_sediment(2),max(matrix(:)))];

        if ~isempty(vs_get_elm_def(F,'NAMTRA')) && ~isempty(OPT.crsind)
            disp('Writing sediment transports...')
            matrix = vs_let(F,'his-sed-series','SBTR',{OPT.crsind,0},OPT.quiet);
            ncwrite(ncfile,'bed_load_transport',permute(matrix,[3 2 1]));
            R.bed_load_transport = [min(R.bed_load_transport(1),min(matrix(:))) max(R.bed_load_transport(2),max(matrix(:)))];

            matrix = vs_let(F,'his-sed-series','SBTRC',{OPT.crsind,0},OPT.quiet);
            ncwrite(ncfile,'cumulative_bed_load_transport',permute(matrix,[3 2 1]));
            R.cumulative_bed_load_transport = [min(R.cumulative_bed_load_transport(1),min(matrix(:))) max(R.cumulative_bed_load_transport(2),max(matrix(:)))];

            matrix = vs_let(F,'his-sed-series','SSTR',{OPT.crsind,0},OPT.quiet);
            ncwrite(ncfile,'suspended_load_transport',permute(matrix,[3 2 1]));
            R.suspended_load_transport = [min(R.suspended_load_transport(1),min(matrix(:))) max(R.suspended_load_transport(2),max(matrix(:)))];

            matrix = vs_let(F,'his-sed-series','SSTRC',{OPT.crsind,0},OPT.quiet);
            ncwrite(ncfile,'cumulative_suspended_load_transport',permute(matrix,[3 2 1]));
            R.cumulative_suspended_load_transport = [min(R.cumulative_suspended_load_transport(1),min(matrix(:))) max(R.cumulative_suspended_load_transport(2),max(matrix(:)))];
        end
    end
   
%% update actual ranges

    if exist('R','var')
        varnames = fieldnames(R);

        for ivar=1:length(varnames)
            varname = varnames{ivar};
            ncwriteatt(ncfile,varname,'actual_range',R.(varname));
        end
    end

    if isnumeric(OPT.dump) && OPT.dump==1
        nc_dump(ncfile);
    else
        fid = fopen(OPT.dump,'w');
        nc_dump(ncfile,fid);
        fclose(fid);
    end
      
%% EOF      
