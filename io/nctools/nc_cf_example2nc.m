%function nc_cf_example2nc
%NC_CF_EXAMPLE2NC   example script to make a netCDF file according to CF convention
%
%   Creates an example netCDF file 'nc_cf_example2nc' that allows one to look
%   at advantages of netCDF with: nc_dump and ncBrowse
%
%See also: NC_CF_EXAMPLE2NCPLOT
%          time series:  knmi_potwind2nc, knmi_etmgeg2nc, getWaterbase2nc
%          grids:        knmi_noaapc2nc
%          points:      
%          linesegments:
%          transects:

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

   OPT.refdatenum = datenum(1970,1,1);
   OPT.fillvalue  = nan;

%% 0 Read raw data
% make a function that returns all data + meta-data in one struct:
%  D             = knmi_potwind(OPT.filename,'variables',OPT.fillvalue);

   D.datenum     = floor(now) + [0:2:24]./24;
   D.version     = 0;
   D.lat         = [ 4  5  6];
   D.lon         = [52 53 54 55];
   D.temperature = repmat(nan,[length(D.datenum) length(D.lat) length(D.lon)]);
   for i=1:length(D.datenum)
   for j=1:length(D.lat)
   for k=1:length(D.lon)
      D.temperature(i,j,k) = i.^2 + (D.lat(j).^2 + D.lon(k));
   end
   end
   end
  %D.temperature = (D.lat,D.lon);
   D.timezone    = '+00:00';

%% 1a Create file
   outputfile = 'nc_cf_example2nc.nc';
   
   nc_create_empty (outputfile)

   %% Add overall meta info
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
   %------------------

   nc_attput(outputfile, nc_global, 'title'         , '');
   nc_attput(outputfile, nc_global, 'institution'   , 'Deltares');
   nc_attput(outputfile, nc_global, 'source'        , '');
   nc_attput(outputfile, nc_global, 'history'       , ['tranformation to NetCDF: $HeadURL']);
   nc_attput(outputfile, nc_global, 'references'    , '<http://openearth.deltares.nl>');
   nc_attput(outputfile, nc_global, 'email'         , '');
   
   nc_attput(outputfile, nc_global, 'comment'       , '');
   nc_attput(outputfile, nc_global, 'version'       , D.version);
						    
   nc_attput(outputfile, nc_global, 'Conventions'   , 'CF-1.4');
   nc_attput(outputfile, nc_global, 'CF:featureType', 'stationTimeSeries');  % https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions
   
   %% OpenEarth convention

   nc_attput(outputfile, nc_global, 'terms_for_use' , 'These data can be used freely for research purposes provided that the following source is acknowledged: KNMI.');
   nc_attput(outputfile, nc_global, 'disclaimer'    , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');

%% 2 Create dimensions

   nc_add_dimension(outputfile, 'time'  , length(D.datenum))
   nc_add_dimension(outputfile, 'lat'   , length(D.lat))
   nc_add_dimension(outputfile, 'lon'   , length(D.lon))

%% 3 Create variables

   clear nc
   ifld = 0;
   
   %% Define dimensions in this order:
   %  time,z,y,x
   %
   %  For standard names see:
   %  http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/standard-name-table

   %% Latitude
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'lat';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {'lat'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'latitude');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_north');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'latitude');

   %% Longitude
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'lon';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {'lon'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'longitude');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_east');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'longitude');

   %% Time
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#time-coordinate
   % time is a dimension, so there are two options:
   % * the variable name needs the same as the dimension
   %   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984551
   % * there needs to be an indirect mapping through the coordinates attribute
   %   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984605
   
   OPT.timezone = timezone_code2iso(D.timezone);

      ifld = ifld + 1;
   nc(ifld).Name         = 'time';
   nc(ifld).Nctype       = 'double'; % float not sufficient as datenums are big: doubble
   nc(ifld).Dimension    = {'time'}; % {'locations','time'} % does not work in ncBrowse, nor in Quickplot (is indirect time mapping)
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'time');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value',['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',OPT.timezone]);
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'time');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
  %nc(ifld).Attribute(5) = struct('Name', 'bounds'         ,'Value', '');
   
   %% Parameters with standard names
   % * http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/

      ifld = ifld + 1;
   nc(ifld).Name         = 'T';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'time','lat','lon'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'air temperature');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'm/s');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'air_temperature');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);

%% 4 Create variables with attibutes
% When variable definitons are created before actually writing the
% data in the next cell, netCDF can nicely fit all data into the
% file without the need to relocate any info.

   for ifld=1:length(nc)
      disp(['adding ',num2str(ifld),' ',nc(ifld).Name])
      nc_addvar(outputfile, nc(ifld));   
   end
   
   D

%% 5 Fill variables

   nc_varput(outputfile, 'time' , D.datenum-OPT.refdatenum);
   nc_varput(outputfile, 'lat'  , D.lat);
   nc_varput(outputfile, 'lon'  , D.lon);
   nc_varput(outputfile, 'T'    , D.temperature);

%% 6 Check

   nc_dump(outputfile);
   
%% EOF   
