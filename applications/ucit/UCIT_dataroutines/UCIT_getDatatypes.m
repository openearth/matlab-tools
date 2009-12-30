function [datatypes] = UCIT_getDatatypes
%UCIT_GETDATATYPES  gets urls of selected datatypes in UCIT
%
%      [datatypes] = UCIT_getDatatypes()
%
%   returns a cellstr with the base paths/OPeNDAP urls or netCDF files of 
%   each of the four UCIT datatypes (transects, grids, lines, points)
%
%   Input: none
%   
%
%   Output: structure with datatypes
%   
%
%   Example: [datatypes] = UCIT_getDatatypes
%   
%
%   See also: UCIT_getMetaData, UCIT_plotLandboundary 

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Ben de Sonneville
%
%       Ben.deSonneville@Deltares.nl	
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

% TO DO: save as datatypes.transect(i).names instead of datatypes.transect.names{i}
% TO DO: megre info on which ldb to plot from UCIT_plotLandboundary to here

%% Transect data

   %% Jarkus

   datatypes.transect.names  {1} =  'Jarkus Data';
   datatypes.transect.urls   {1} =  'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/jarkus/profiles/transect.nc';
   datatypes.transect.areas  {1} =  '';
   datatypes.transect.catalog{1} =  'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/jarkus/profiles/catalog.xml';
   
   %% Lidar USA

   datatypes.transect.names{2}   =  'Lidar Data US';
   datatypes.transect.urls {2}   = {'http://blackburn.whoi.edu:8081/thredds/dodsC/usgs/afarris/oregon_7.nc',...
                                    'http://blackburn.whoi.edu:8081/thredds/dodsC/usgs/afarris/washington_1.nc'};
                         
   datatypes.transect.areas{2}   = {'Oregon','Washington'};
   datatypes.transect.catalog{1} =  'http://blackburn.whoi.edu:8081/thredds/dodsC/usgs/afarris/catalog.xml';

   % datatypes.transect.areas_short = {'',{'or','wa'}};

%% Grid data

   %% Jarkus

   datatypes.grid.names{1}       =  'Jarkus';
   datatypes.grid.urls {1}       =  'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/';
   datatypes.grid.catalog{1}     =  'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/jarkus/grids/catalog.xml';

   %% Vaklodingen

   datatypes.grid.names{2}       =  'Vaklodingen';
   datatypes.grid.urls {2}       =  'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/';
   datatypes.grid.catalog{2}     =  'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml';

   %% AHN100

   datatypes.grid.names{3}       =  'AHN100';
   datatypes.grid.urls {3}       =  'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/tno/ahn100m/mv100.nc';
   datatypes.grid.catalog{3}     =  'http://opendap.deltares.nl/thredds/catalog/opendap/tno/ahn100m/catalog.xml';

   %% AHN250

   datatypes.grid.names{4}       =  'AHN250'; % note 250 is in 100 directory on server
   datatypes.grid.urls {4}       =  'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/tno/ahn100m/mv250.nc';
   datatypes.grid.catalog{4}     =  'http://opendap.deltares.nl/thredds/catalog/opendap/tno/ahn100m/catalog.xml';
                          
%% Lines data

%% Point data
   






