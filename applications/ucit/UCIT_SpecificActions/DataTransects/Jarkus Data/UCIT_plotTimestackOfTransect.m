function UCIT_plotTimestackOfTransect(datatype, area, transectID)
%PLOTTIMESTACKOFTRANSECT   routine plots time stack of transect
%
% input:
%   datatype
%   areaname
%   transectId
%
% output:
%   timestack plot
%
% syntax:
%           
%
%   See also 
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

datatypes = UCIT_getDatatypes;
url = datatypes.transect.urls{find(strcmp(UCIT_getInfoFromPopup('TransectsDatatype'),datatypes.transect.names))};

if nargin ==0
    [check]=UCIT_checkPopups(1, 3);
    if check == 0
        return
    end
    datatype = UCIT_getInfoFromPopup('TransectsDatatype');
    area = UCIT_getInfoFromPopup('TransectsArea');
    transectID = UCIT_getInfoFromPopup('TransectsTransectID');
end


   

%  d = jarkus_readTransectDataNetcdf(url, UCIT_getInfoFromPopup('TransectsArea'),UCIT_getInfoFromPopup('TransectsTransectID'),years(i));

areaname = cellstr(nc_varget(url, 'areaname'));
alongshoreCoordinates = nc_varget(url, 'alongshore');
crossShoreCoordinate = nc_varget(url, 'cross_shore');
time = nc_varget(url, 'time');

areaIndex = strcmp(areaname,area);
alongshoreIndex =  alongshoreCoordinates == str2double(transectID);
id_index = find(areaIndex & alongshoreIndex);

xi =repmat(crossShoreCoordinate,1,length(time));
zi = nc_varget(url, 'altitude', [0, id_index-1, 0], [length(time), 1, length(crossShoreCoordinate)])';

years = time' + datenum(1970,1,1);


nameInfo = ['UCIT - Timestack window'];
fh = figure('tag','plotWindowTimestack'); clf; ah=axes;
set(fh,'Name', nameInfo,'NumberTitle','Off','Units','normalized');
[fh,ah] = UCIT_prepareFigureN(0, fh, 'UL', ah);
hold on

surf(years,xi,zi);
shading interp;
view(2);
datetick
title([area '-' transectID]);
colorbar;
