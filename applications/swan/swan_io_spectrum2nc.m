function swan_io_spectrum2nc(S,ncfile)
%swan_io_spectrum2nc save spectral structure as netCDF-CF
%
% swan_io_spectrum2nc(S,ncfile) saves struct S to netCDF file,
% where S = swan_io_spectrum or can be constructed otherwise.
% swan_io_spectrum2nc uses the same variable names as SWAN netCDF 
% itself (agioncmd.f90), so it should be able to use swan_io_spectrum2nc
% to construct SWAN netCDF input.
%
%See also: swan_io_spectrum, netcdf

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Van Oord
%       Gerben de Boer, <gerben.deboer@vanoord.com>
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 09 Nov 2012
% Created with Matlab version: 8.0.0.783 (R2012b)

% $Id: running_median_filter.m 10097 2014-01-29 23:02:09Z boer_g $
% $Date: 2014-01-30 00:02:09 +0100 (Thu, 30 Jan 2014) $
% $Author: boer_g $
% $Revision: 10097 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/signal_fun/running_median_filter.m $
% $Keywords: $

%% detect all switches

% coordinates

    if isfield(S,'lon')
        x = 'lon';OPT.x.name = 'longitude';OPT.x.units = 'degrees_east' ;OPT.x.cf = 'longitude';
        y = 'lat';OPT.x.name = 'latitude' ;OPT.y.units = 'degrees_north';OPT.y.cf = 'latitude';
    else
        x = 'x'  ;OPT.x.name = 'x';        OPT.x.units = 'm'            ;OPT.x.cf = 'projection_x_coordinate';
        y = 'y'  ;OPT.x.name = 'y';        OPT.y.units = 'm'            ;OPT.y.cf = 'projection_y_coordinate';
    end

% multi dimensional coordinates

    if isvector(S.(x))
        OPT.mdc    = false;
    else
        OPT.mdc    = true;
    end

% non-stationary mode (time /run switch)

    if isfield(S,'time')
        OPT.nstatm = true ;
    else
        OPT.nstatm = false ;
    end
    
% 1d or 2d

	OPT.ndir = 0;
    if   isfield(S,'directions')
        OPT.ndir = length(S.directions);
        if strcmpi(S.direction_convention,'nautical')
            OPT.d.cf     = 'sea_surface_wave_from_direction';
            OPT.nautical = true;
        else
            OPT.d.cf     = 'sea_surface_wave_to_direction';
            OPT.nautical = false;
        end
    else
        if     isfield(S,'NDIR')
            OPT.d.name = 'spread_1d';OPT.d.units = 'degrees'; OPT.d.cf = 'sea_surface_wave_from_direction';
            OPT.nautical = true;
        elseif isfield(S,'CDIR')
            OPT.d.name = 'spread_1d';OPT.d.units = 'degrees'; OPT.d.cf = 'sea_surface_wave_to_direction';
            OPT.nautical = false;
        end        
    end    

%

    if strcmpi(S.frequency_type,'absolute')
        OPT.relative_to_current = 0;% netcdf can't handle logicala
    else
        OPT.relative_to_current = 1;
    end

%%
   nc.Name   = '/';
   nc.Format = '64bit'; % 10 GB
   
   nc.Attributes(    1) = struct('Name','title'              ,'Value',  'SWAN sxpectrum');
   nc.Attributes(end+1) = struct('Name','institution'        ,'Value',  'Tu Delft');
   nc.Attributes(end+1) = struct('Name','source'             ,'Value',  '');
   nc.Attributes(end+1) = struct('Name','history'            ,'Value',  '$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/ncwritetutorial_grid_lat_lon_curvilinear.m $ $Id: ncwritetutorial_grid_lat_lon_curvilinear.m 8907 2013-07-10 12:39:16Z boer_g $');
   nc.Attributes(end+1) = struct('Name','references'         ,'Value',  'http://svn.oss.deltares.nl');
   nc.Attributes(end+1) = struct('Name','email'              ,'Value',  '');
   nc.Attributes(end+1) = struct('Name','featureType'        ,'Value',  '');

   nc.Attributes(end+1) = struct('Name','comment'            ,'Value',  '');
   nc.Attributes(end+1) = struct('Name','version'            ,'Value',  '');

   nc.Attributes(end+1) = struct('Name','Conventions'        ,'Value',  'CF-1.9');

   nc.Attributes(end+1) = struct('Name','terms_for_use'      ,'Value',  'please specify');
   nc.Attributes(end+1) = struct('Name','disclaimer'         ,'Value',  'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');
   
   nc.Attributes(end+1) = struct('Name','time_coverage_start','Value',datestr(min(S.time),'yyyy-mm-ddTHH:MM'));
   nc.Attributes(end+1) = struct('Name','time_coverage_end'  ,'Value',datestr(max(S.time),'yyyy-mm-ddTHH:MM'));
   
   
%% Dimensions   
   
   nc.Dimensions(    1) = struct('Name', 'time'             ,'Length',length(S.time      ));m.t = 1;
   nc.Dimensions(end+1) = struct('Name', 'frequency'        ,'Length',length(S.frequency ));m.f = length(nc.Dimensions);
   
   if OPT.mdc
   nc.Dimensions(end+1) = struct('Name', 'xc'               ,'Length',length(S.(x)       ));m.x = length(nc.Dimensions);
   nc.Dimensions(end+1) = struct('Name', 'yc'               ,'Length',length(S.(x)       ));m.y = length(nc.Dimensions);m.xy = [m.x m.y];
   else
   nc.Dimensions(end+1) = struct('Name', 'location'         ,'Length',length(S.(x)       ));m.x = length(nc.Dimensions);m.xy = m.x;
   end
   
   if isfield(S,'directions')
   nc.Dimensions(end+1) = struct('Name', 'direction'        ,'Length',length(S.directions));m.d = length(nc.Dimensions); %  NB dropping of -s
   end
                 
%% swap variable dimensions following C convention, and mimic agioncmd.ftn90

   M.time         = struct('Name','units'        ,'Value','days since 1970-01-01');
   
   M.frequency    = struct('Name','units'        ,'Value','s-1');
   M.frequency(2) = struct('Name','standard_name','Value','wave_frequency');
   
   M.x            = struct('Name','units'        ,'Value',OPT.x.units);
   M.x(end+1)     = struct('Name','standard_name','Value',OPT.x.cf);

   M.y            = struct('Name','units'        ,'Value',OPT.y.units);
   M.y(end+1)     = struct('Name','standard_name','Value',OPT.y.cf);
   
   nc.Variables(    1) = struct('Name','time'     ,'Datatype','double','Dimensions',nc.Dimensions([m.t  ]),'Attributes',M.time);
   nc.Variables(end+1) = struct('Name','frequency','Datatype','double','Dimensions',nc.Dimensions([m.f  ]),'Attributes',M.frequency);  
   nc.Variables(end+1) = struct('Name','x'        ,'Datatype','double','Dimensions',nc.Dimensions([m.xy ]),'Attributes',M.x);
   nc.Variables(end+1) = struct('Name','y'        ,'Datatype','double','Dimensions',nc.Dimensions([m.xy ]),'Attributes',M.y);  
   if isfield(m,'d')
       
   M.d            = struct('Name','units'        ,'Value','degrees');
   M.d(end+1)     = struct('Name','standard_name','Value',OPT.d.cf);
   
   nc.Variables(end+1) = struct('Name','direction','Datatype','double','Dimensions',nc.Dimensions([m.d  ]),'Attributes',M.d);
   end

%%
   for i=1:length(S.quantity_names)
       varcode = S.quantity_names{i};
       
       if     strcmpi(varcode,'VaDens') | strcmpi(varcode,'EnDens')
           
        M.VaDens(    1) = struct('Name','long_name',     'Value','energy');
        M.VaDens(end+1) = struct('Name','units'        , 'Value',S.quantity_units{i});
        M.VaDens(end+1) = struct('Name','standard_name', 'Value','sea_surface_wave_variance_spectral_density');
        M.VaDens(end+1) = struct('Name','swan_code',     'Value',varcode);
        M.VaDens(end+1) = struct('Name','swan_name',     'Value',varcode);
        M.VaDens(end+1) = struct('Name','swan_long_name','Value',S.quantity_names_long{i});
        M.VaDens(end+1) = struct('Name','relative_to_current','Value',OPT.relative_to_current);
        
        
        if OPT.ndir > 0
        nc.Variables(end+1) = struct('Name','energy'   ,'Datatype','double','Dimensions',nc.Dimensions([m.xy m.f m.d m.t]),'Attributes',M.VaDens);
        S.nc_names{i} = 'energy';
        else
        nc.Variables(end+1) = struct('Name','energy_1d','Datatype','double','Dimensions',nc.Dimensions([m.xy m.f     m.t]),'Attributes',M.VaDens);
        S.nc_names{i} = 'energy_1d';
        end
        
       
       elseif strcmpi(varcode,'NDIR') | strcmpi(varcode,'CDIR')
           
        M.DIR(    1) = struct('Name','long_name'     ,'Value','principal wave direction');
        M.DIR(end+1) = struct('Name','units'         ,'Value',OPT.d.units);
        M.DIR(end+1) = struct('Name','standard_name' ,'Value',OPT.d.cf);
        M.DIR(end+1) = struct('Name','swan_code'     ,'Value',varcode);
        M.DIR(end+1) = struct('Name','swan_name'     ,'Value',varcode);
        M.DIR(end+1) = struct('Name','swan_long_name','Value',S.quantity_names_long{i});
        nc.Variables(end+1) = struct('Name','theta_1d' ,'Datatype','double','Dimensions',nc.Dimensions([m.xy m.f     m.t]),'Attributes',M.DIR);
        S.nc_names{i} = 'theta_1d';
        
       elseif strcmpi(varcode,'DSPRDEGR') 
           
        M.DSPRDEGR(    1) = struct('Name','long_name'     ,'Value','Longuet-Higgins short-crestedness parameter (s in cos(theta/2)^2s)');
        M.DSPRDEGR(end+1) = struct('Name','units'         ,'Value','degrees');
        M.DSPRDEGR(end+1) = struct('Name','swan_code'     ,'Value',varcode);        
        M.DSPRDEGR(end+1) = struct('Name','swan_name'     ,'Value',varcode);        
        M.DSPRDEGR(end+1) = struct('Name','swan_long_name','Value',S.quantity_names_long{i});        
        nc.Variables(end+1) = struct('Name','spread_1d','Datatype','double','Dimensions',nc.Dimensions([m.xy m.f     m.t]),'Attributes',M.DSPRDEGR);
        S.nc_names{i} = 'spread_1d';
       
       end
   end

   %var2evalstr(nc)
   ncwriteschema(ncfile, nc);
   ncdisp(ncfile)
   nc_dump(ncfile,'',[filepathstrname(ncfile),'.cdl'])
   
%% write
    ncwrite(ncfile,'time'     ,S.time - datenum(1970,0,0))
    ncwrite(ncfile,'x'        ,S.(x))
    ncwrite(ncfile,'y'        ,S.(y))
    ncwrite(ncfile,'frequency',S.frequency);
    if OPT.ndir > 1
    ncwrite(ncfile,'direction',S.directions); %  NB dropping of -s
    end
    for ivar=1:length(S.quantity_names)
    ncwrite(ncfile,S.nc_names{i},S.(S.quantity_names{i}))
    end
