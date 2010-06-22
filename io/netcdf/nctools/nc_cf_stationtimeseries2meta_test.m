function testResult = nc_cf_stationtimeseries2meta_test()
% NC_CF_STATIONTIMESERIES2META_TEST  test for nc_cf_stationtimeseries2meta
%  
% This file tests nc_cf_stationtimeseries2meta.
%
%
%   See also nc_cf_stationtimeseries2meta 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 22 Jun 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

TeamCity.category('UnCategorized');

if TeamCity.running
    TeamCity.ignore('WIP: generates error after about 450 files: java.lang.OutOfMemoryError: Java heap space');
    return;
end

%% Note: generates error after about 450 files:
%     java.lang.OutOfMemoryError: Java heap space
%
% Note that that opendap acces does not work then (landboundary)

OPT.USE_JAVA = getpref ('SNCTOOLS', 'USE_JAVA');
setpref ('SNCTOOLS', 'USE_JAVA', 0)

%% ------------------------

%  OPT.subdirs = {'concentration_of_chlorophyll_in_sea_water',...
%                 'concentration_of_suspended_matter_in_sea_water',...
%                 'sea_surface_height',...
%                 'sea_surface_salinity',...
%                 'sea_surface_temperature',...
%                 'sea_surface_wave_from_direction',...
%                 'sea_surface_wave_significant_height',...
%                 'sea_surface_wind_wave_mean_period_from_variance_spectral_density_second_frequency_moment'};
%                 
%  for ii=1:length(OPT.subdirs)            
%  
%  [M,units] = nc_cf_stationtimeseries2meta('directory_nc',['P:\mcdata\opendap\rijkswaterstaat\waterbase\',OPT.subdirs{ii}],...
%                                          'standard_name',OPT.subdirs{ii});
%  
%  end

%% ------------------------

  OPT.subdirs = {'etmgeg'%,...
                 };%'potwind'};
                 
  for ii=1:length(OPT.subdirs)            
  
  nc_cf_stationtimeseries2meta('directory_nc',['P:\mcdata\opendap\knmi\',OPT.subdirs{ii}],...
                              'standard_names',{'wind_speed','wind_from_direction'});
  
  end


%% ------------------------
               
setpref ('SNCTOOLS', 'USE_JAVA', OPT.USE_JAVA)

%% EOF
