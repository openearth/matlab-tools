function varargout = nc_cf_grid_mapping(epsg,varargin)
%NC_CF_GRID_MAPPING   get CF/ADAGUC grid mapping nc attributes from epsg code
%
%    S = nc_cf_grid_mapping(epsg)
%
% where struct S can be used as the set of attributes 
% of the grid_mapping variable as described in
% http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#grid-mappings-and-projections
% http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#appendix-grid-mappings
% it also contains the ADAGUC parameters
% http://....
%
% where WKT   is the well-known-text representation.
% where proj4 is the proj4 keyword,value string
%
% Example:
%
%    S = nc_cf_grid_mapping(23031) % 'ED50 / UTM zone 31N'
%    nc.Name         = 'crs';
%    nc.Nctype       = nc_int;
%    nc.Dimension    = {};
%    nc.Attribute    = S;
%    nc_addvar(ncfile, nc);  
%
% CF knows the folowing attributes
% * grid_mapping_name
% * semi_major_axis
% * semi_minor_axis
% * inverse_flattening
% * latitude_of_projection_origin
% * longitude_of_projection_origin
% * false_easting
% * false_northing
% * scale_factor_at_projection_origin
% For plotting with the ADAGUC package, additional keywords are required:
% * projection_name
% * EPSG_code
% * proj4_params (via http://spatialreference.org/ref/)
% WKT
% * wkt (via http://spatialreference.org/ref/)
%
%see also: convertcoordinates, nc_cf_grid

%%  --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares for Building with Nature
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

% TO DO: fill WKT   with parameters automatically
% TO DO: fill proj4 with parameters automatically

OPT.debug = 0;

%% EPSG: includes CF parameter

   [dummy,dummy,log] = convertcoordinates(1,1,'CS1.code',epsg,'CS2.code',4326);

   if OPT.debug
      var2evalstr(log)
   end


%% get proj4 string
%  needed to make netCDf file ADAGUC compliant
%  for now a lookup table, needs to be a proper function (web service or osgeo warapper)

      try
         switch num2str(epsg)
         case '28992' % here webservice is off !!
         OPT.proj4_params = '+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.999908 +x_0=155000 +y_0=463000 +ellps=bessel +units=m +towgs84=565.4174,50.3319,465.5542,-0.398957388243134,0.343987817378283,-1.87740163998045,4.0725 +no_defs'; % note that epsg tables are wrong for 28992, need to specify ellipsoid explicity manually !
         otherwise
         OPT.proj4_params = urlread(['http://spatialreference.org/ref/epsg/',num2str(epsg),'/proj4/']);
         end
      catch
         OPT.proj4_params = '';
         warning('cannot get proj4_params, please work online to be able to access http://spatialreference.org')
      end

%% get WKT string via web service

      try
         OPT.wkt = urlread(['http://spatialreference.org/ref/epsg/',num2str(epsg),'/prettywkt/']);
      catch
         OPT.wkt = '';
         warning('cannot get pretty wkt, please work online to be able to access http://spatialreference.org')
      end

%% get human readable string

      switch epsg
      case  4326, OPT.projection_name = 'Latitude Longitude';
      case 28992, OPT.projection_name = 'Dutch rijksdriekhoek system';
      otherwise,  
         if ~strcmpi(log.CS1.type,'geographic 2D'); % e.g. ED50 4230, WGS84 4326
            OPT.projection_name = log.CS1.name;
         else
            OPT.projection_name = log.CS2.name;
         end
      end

%% TO DO: use Appendix F. Grid Mappings
% -------------------------
% . albers_conical_equal_area
% . azimuthal_equidistant
% . lambert_azimuthal_equal_area
% . lambert_conformal_conic
% . lambert_cylindrical_equal_area
% . latitude_longitude
% . mercator
% . orthographic
% . polar_stereographic
% . rotated_latitude_longitude
% . stereographic
% x transverse_mercator
% . vertical_perspective

if ~strcmpi(log.CS1.type,'geographic 2D'); % e.g. ED50 4230, WGS84 4326

   if strcmpi(log.proj_conv1.method.name,'Transverse Mercator') OPT.grid_mapping_name = 'transverse_mercator'
   else                                                         OPT.grid_mapping_name = '';
   end

   S = struct('Name', ...
    {'name',...                             % CF
     'epsg',...                             % CF
     'epsg_name',...                        % CF
     'grid_mapping_name',...                % CF
     'semi_major_axis',...                  % CF
     'semi_minor_axis',...                  % CF
     'inverse_flattening',...               % CF
     'latitude_of_projection_origin',...    % CF
     'longitude_of_projection_origin',...   % CF
     'false_easting',...                    % CF
     'false_northing',...                   % CF
     'scale_factor_at_projection_origin',...% CF
     'proj4_params',...                     % ADAGUC
     'EPSG_code',...                        % ADAGUC
     'projection_name',...                  % ADAGUC
     'wkt',...                              % WKT
     'comment'}, ...
     'Value', ...
     {log.CS1.name,...
      epsg,     ...
      log.proj_conv1.method.name,     ...
      OPT.grid_mapping_name,     ...
      log.CS1.ellips.semi_major_axis, ...
      log.CS1.ellips.semi_minor_axis, ...
      log.CS1.ellips.inv_flattening,  ...
      log.proj_conv1.param.value(strcmp(log.proj_conv1.param.name,'Latitude of natural origin'    )),...
      log.proj_conv1.param.value(strcmp(log.proj_conv1.param.name,'Longitude of natural origin'   )),...
      log.proj_conv1.param.value(strcmp(log.proj_conv1.param.name,'False easting'                 )),...
      log.proj_conv1.param.value(strcmp(log.proj_conv1.param.name,'False northing'                )),...
      log.proj_conv1.param.value(strcmp(log.proj_conv1.param.name,'Scale factor at natural origin')),...
      OPT.proj4_params,...
      ['EPSG:',num2str(epsg)],...
      OPT.projection_name,...
      OPT.wkt,...
     'value is equal to EPSG code'});
     
else        


   S = struct('Name', ...
    {'name',...                             % CF
     'epsg', ...                            % CF
     'grid_mapping_name',...                % CF
     'semi_major_axis',...                  % CF
     'semi_minor_axis',...                  % CF
     'inverse_flattening',...               % CF
     'proj4_params',...                     % ADAGUC
     'EPSG_code',...                        % ADAGUC
     'projection_name',...                  % ADAGUC
     'wkt',...                              % WKT
     'comment'}, ...
     'Value', ...
     {log.CS2.name,...
      epsg,     ...
     'latitude_longitude',...
      log.CS2.ellips.semi_major_axis, ...
      log.CS2.ellips.semi_minor_axis, ...
      log.CS2.ellips.inv_flattening,  ...
      OPT.proj4_params,...
      ['EPSG:',num2str(epsg)],...
      OPT.projection_name,...
      OPT.wkt,...
     'value is equal to EPSG code'});
     
end

%% out

if OPT.debug
   var2evalstr(S)
end

if nargout==1

   varargout = {S};

else
   WKT = epsg_wkt(epsg) ;
   varargout = {S,WKT};

end
