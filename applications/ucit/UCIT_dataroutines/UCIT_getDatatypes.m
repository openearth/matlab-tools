function [datatypes] = UCIT_getDatatypes
%UCIT_GETDATATYPES  gets urls of selected datatypes in UCIT
%
%   
%
%   Syntax:
%   
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
%   See also getUcitMetaData

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
% datatypes.transect.names = {'Jarkus Data'};

datatypes.transect.names = {'Jarkus Data' ,...
                            'Lidar Data US'};
                        

datatypes.transect.urls = {'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/jarkus/profiles/transect.nc';...
                           'd:\OpenEarthRawData\lidar\oregon_6.nc'};
