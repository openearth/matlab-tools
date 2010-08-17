function varargout = nc_t_tide(t,var,varargin)
%NC_T_TIDE    t_tide with netCDF output
%
%   nc_t_tide(t,var,<keyword,value>)
%
% performs a t_tide tidal analysis and saved result as netCDF file.
% For list of <keyword,value> call nc_t_tide()
%
%See also: T_TIDE

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Gerben J. de Boer
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 17 Aug 2010
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Input

   OPT.station_id   = '';
   OPT.station_name = '';
   OPT.period       = [];
   OPT.lat          = NaN;
   OPT.lon          = NaN;
   OPT.units        = '?';
   OPT.ascfile      = '';
   OPT.ncfile       = '';
   OPT.ddatenumeps  = 1e-8;

   OPT = setProperty(OPT,varargin{:});
   
   if nargin==0
      varargout = {OPT};
      return
   end

%% Tidal analysis incl. temporal equidistance check
   
      dt = diff(t);
   
      if length(unique([dt])) > 1
         if (max(dt) - min(dt)) > OPT.ddatenumeps
            error('No equidistant time intervals.')
         end
      end
   
      [tidestruc,pout]=t_tide(var,...
                 'latitude'  ,OPT.lat,... % required for nodal corrections
                 'start'     ,t(1),...
                 'interval'  ,dt(1)*24,... % in hours
                 'output'    ,[OPT.ascfile]);
                 
%% Collect relevant data in struct, as if returned by D = nc2struct()                 

      D.station_id     = OPT.station_id  ;  
      D.station_name   = OPT.station_name;
      D.longitude      = OPT.lon;
      D.latitude       = OPT.lat;
      D.time           = OPT.period(1) - datenum(1970,1,1);
      D.period         = OPT.period' - datenum(1970,1,1);
      D.component_name = tidestruc.name;
      D.frequency      = tidestruc.freq;
      D.amplitude      = tidestruc.tidecon(:,1);
      D.phase          = tidestruc.tidecon(:,3);
      D
                 
%% Save struct to netCDF fi;e
      
      nc_create_empty(OPT.ncfile);
      
% TO DO: add other meta-info from t_tide such as history and stuff from t_tide ASCII file
      
      nc_adddim      (OPT.ncfile,'frequency',size(tidestruc.name,1));
      nc_adddim      (OPT.ncfile,'strlen0'  ,size(tidestruc.name,2));
      nc_adddim      (OPT.ncfile,'strlen1'  ,length(OPT.station_id));
      nc_adddim      (OPT.ncfile,'strlen2'  ,length(OPT.station_name));
      nc_adddim      (OPT.ncfile,'time'     ,1);
      nc_adddim      (OPT.ncfile,'bounds'   ,2);

      nc.Name = 'station_id';
      nc.Datatype     = 'char';
      nc.Dimension    = {'strlen1'};
      nc.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'Rijkswaterstaat DONAR code of station');
      nc.Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'station_id');
      nc_addvar         (OPT.ncfile,nc);
      nc_varput         (OPT.ncfile,nc.Name,D.station_id);clear nc

      nc.Name = 'station_name';
      nc.Datatype     = 'char';
      nc.Dimension    = {'strlen2'};
      nc.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'name of station');
      nc.Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'station_name');
      nc_addvar         (OPT.ncfile,nc);
      nc_varput         (OPT.ncfile,nc.Name,D.station_name);clear nc

      nc.Name = 'longitude';
      nc.Datatype     = 'double';
      nc.Dimension    = {};
      nc.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'longitude');
      nc.Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'longitude');
      nc.Attribute(3) = struct('Name', 'units'          ,'Value', 'degrees_east');
      nc_addvar         (OPT.ncfile,nc);
      nc_varput         (OPT.ncfile,nc.Name,D.longitude);clear nc

      nc.Name = 'latitude';
      nc.Datatype     = 'double';
      nc.Dimension    = {};
      nc.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'latitude');
      nc.Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'latitude');
      nc.Attribute(3) = struct('Name', 'units'          ,'Value', 'degrees_north');
      nc_addvar         (OPT.ncfile,nc);
      nc_varput         (OPT.ncfile,nc.Name,D.latitude);clear nc

      nc.Name = 'time';
      nc.Datatype     = 'double';
      nc.Dimension    = {'time'};
      nc.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'begin of interval of tidal analysis');
      nc.Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'time');
      nc.Attribute(3) = struct('Name', 'units'          ,'Value', 'days since 1970-01-01 00:00:00 +01:00');
      nc.Attribute(4) = struct('Name', 'bounds'         ,'Value', 'period');
      nc_addvar         (OPT.ncfile,nc);
      nc_varput         (OPT.ncfile,nc.Name,D.time);clear nc

      nc.Name = 'period';
      nc.Datatype     = 'double';
      nc.Dimension    = {'time','bounds'};
      nc.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'begin and end of interval of tidal analysis');
      nc.Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'time');
      nc.Attribute(3) = struct('Name', 'units'          ,'Value', 'days since 1970-01-01 00:00:00 +01:00');
      nc_addvar         (OPT.ncfile,nc);
      nc_varput         (OPT.ncfile,nc.Name,D.period);clear nc

% TO DO: make vector orientation irrelevant (hmm, thought I fixed that)

      nc.Name = 'component_name';
      nc.Datatype     = 'char';
      nc.Dimension    = {'frequency','strlen0'};
      nc.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'name of tidal constituent');
      nc_addvar         (OPT.ncfile,nc);
      nc_varput         (OPT.ncfile,nc.Name,D.component_name);clear nc
      
      nc.Name = 'frequency';
      nc.Datatype     = 'double';
      nc.Dimension    = {'frequency'};
      nc.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'frequency');
      nc.Attribute(2) = struct('Name', 'units'          ,'Value', '1/hour');
      nc_addvar         (OPT.ncfile,nc);
      nc_varput         (OPT.ncfile,nc.Name,D.frequency);clear nc
      
      nc.Name = 'amplitude';
      nc.Datatype     = 'double';
      nc.Dimension    = {'frequency'};
      nc.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'amplitude of tidal component');
      nc.Attribute(2) = struct('Name', 'units'          ,'Value', OPT.units);
      nc.Attribute(3) = struct('Name', 'cell_methods'   ,'Value', 'time: period area: point');
      nc_addvar         (OPT.ncfile,nc);
      nc_varput         (OPT.ncfile,nc.Name,D.amplitude);clear nc
      
      nc.Name = 'phase';
      nc.Datatype     = 'double';
      nc.Dimension    = {'frequency'};
      nc.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'phase of tidal component');
      nc.Attribute(2) = struct('Name', 'units'          ,'Value', 'degree');
      nc.Attribute(3) = struct('Name', 'cell_methods'   ,'Value', 'time: period area: point');
      nc_addvar         (OPT.ncfile,nc);
      nc_varput         (OPT.ncfile,nc.Name,D.phase);clear nc

if nargout==1
   varargout = {D};
end   
