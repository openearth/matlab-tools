function varargout = nc_cf_grid_mapping(epsg,varargin)
%NC_CF_GRID_MAPPING   get CF mapping attributes from epsg code
%
%    S        = nc_cf_grid_mapping(epsg)
%   [S,<WKT>] = nc_cf_grid_mapping(epsg)
%
% where struct S can be used as the set of attributes 
% of the grid_mapping variable as described in
% http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#grid-mappings-and-projections
% http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#appendix-grid-mappings
%
% where WKT is the well-known-text representation.
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

% TO DO: fill WKT with parameters automatically

OPT.debug = 0;

[dummy,dummy,log] = convertcoordinates(1,1,'CS1.code',epsg,'CS2.code',4326);

if OPT.debug
   var2evalstr(log)
end

% TO DO: use Appendix F. Grid Mappings
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
       {'name',...
        'epsg', ...
        'epsg_name', ...
        'grid_mapping_name',...
        'semi_major_axis', ...
        'semi_minor_axis', ...
        'inverse_flattening', ...
        'latitude_of_projection_origin', ...
        'longitude_of_projection_origin', ...
        'false_easting', ...
        'false_northing', ...
        'scale_factor_at_projection_origin', ...
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
        'value is equal to EPSG code'});
else        

   S = struct('Name', ...
    {'name',...
     'epsg', ...
     'grid_mapping_name',...
     'semi_major_axis', ...
     'semi_minor_axis', ...
     'inverse_flattening', ...
     'comment'}, ...
     'Value', ...
     {log.CS2.name,...
      epsg,     ...
     'latitude_longitude',...
      log.CS2.ellips.semi_major_axis, ...
      log.CS2.ellips.semi_minor_axis, ...
      log.CS2.ellips.inv_flattening,  ...
     'value is equal to EPSG code'});
     
end

if OPT.debug
   var2evalstr(S)
end

if nargout==1

   varargout = {S};

else
   WKT = epsg_wkt(epsg) ;
   varargout = {S,WKT};

end
