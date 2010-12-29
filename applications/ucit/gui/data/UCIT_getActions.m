function [datatypes] = UCIT_getActions;
%UCIT_GETDATATYPES  gets urls of selected datatypes in UCIT
%
%      [datatypes] = UCIT_getActions()
%
%   returns a cellstr with the relevant actions of
%   each of the four UCIT datatypes (transects, grids, lines, points)
%
%   Input: none
%
%
%   Output: structure with datatypes
%
%
%   Example: [datatypes] = UCIT_getActions
%
%
%   See also: UCIT_getDatatypes

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
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
% add data type

i = 0;

%% Transect data
%  NOTE: Keep this file consistent with UCIT_getDatatypes!

%% Jarkus
i = i + 1;
datatypes.transect.commonactions{i}     =  {'UCIT_plotTransectOverview','UCIT_exportTransects2GoogleEarth','UCIT_selectTransect','UCIT_showTransectOnOverview'};
datatypes.transect.specificactions{i}   =  {'UCIT_analyseTransectVolume','UCIT_calculateMKL','UCIT_calculateTKL','UCIT_plotMultipleYears','UCIT_plotTransect'};

%% Jarkus (test)
i = i + 1;
datatypes.transect.commonactions{i}     =  {'UCIT_plotTransectOverview','UCIT_exportTransects2GoogleEarth','UCIT_selectTransect','UCIT_showTransectOnOverview'};
datatypes.transect.specificactions{i}   =  {'UCIT_analyseTransectVolume','UCIT_calculateMKL','UCIT_calculateTKL','UCIT_plotMultipleYears','UCIT_plotTransect'};


%% Lidar USA
i = i + 1;
datatypes.transect.commonactions{i}     =  {'UCIT_plotTransectOverview','UCIT_exportTransects2GoogleEarth','UCIT_selectTransect','UCIT_showTransectOnOverview'};
datatypes.transect.specificactions{i}   =  {'UCIT_plotMultipleTransects','UCIT_plotLidarTransect','UCIT_plotDotsInPolygon','UCIT_plotDots','UCIT_plotAlongshore'};


%% Grid data
%  names are a unique tag, datatype governs the actions

i = 0;

%% Jarkus

i = i + 1;
datatypes.grid.commonactions{i}     =  {'UCIT_getCrossSection','UCIT_IsohypseInPolygon','UCIT_plotDataInGoogleEarth','UCIT_plotDataInPolygon','UCIT_plotDifferenceMap','UCIT_plotGridOverview','UCIT_sandBalanceInPolygon'};
datatypes.grid.specificactions{i}   =  {''};

%% Jarkus (test)

i = i + 1;
datatypes.grid.commonactions{i}     =  {'UCIT_getCrossSection','UCIT_IsohypseInPolygon','UCIT_plotDataInGoogleEarth','UCIT_plotDataInPolygon','UCIT_plotDifferenceMap','UCIT_plotGridOverview','UCIT_sandBalanceInPolygon'};
datatypes.grid.specificactions{i}   =  {''};


%% Vaklodingen

i = i + 1;
datatypes.grid.commonactions{i}     =  {'UCIT_getCrossSection','UCIT_IsohypseInPolygon','UCIT_plotDataInGoogleEarth','UCIT_plotDataInPolygon','UCIT_plotDifferenceMap','UCIT_plotGridOverview','UCIT_sandBalanceInPolygon'};
datatypes.grid.specificactions{i}   =  {''};

%% Vaklodingen (test)

i = i + 1;
datatypes.grid.commonactions{i}     =  {'UCIT_getCrossSection','UCIT_IsohypseInPolygon','UCIT_plotDataInGoogleEarth','UCIT_plotDataInPolygon','UCIT_plotDifferenceMap','UCIT_plotGridOverview','UCIT_sandBalanceInPolygon'};
datatypes.grid.specificactions{i}   =  {''};

%% Kustlidar

i = i + 1;
datatypes.grid.commonactions{i}     =  {'UCIT_getCrossSection','UCIT_IsohypseInPolygon','UCIT_plotDataInGoogleEarth','UCIT_plotDataInPolygon','UCIT_plotDifferenceMap','UCIT_plotGridOverview','UCIT_sandBalanceInPolygon'};
datatypes.grid.specificactions{i}   =  {''};

%% Kustlidar (test)

i = i + 1;
datatypes.grid.commonactions{i}     =  {'UCIT_getCrossSection','UCIT_IsohypseInPolygon','UCIT_plotDataInGoogleEarth','UCIT_plotDataInPolygon','UCIT_plotDifferenceMap','UCIT_plotGridOverview','UCIT_sandBalanceInPolygon'};
datatypes.grid.specificactions{i}   =  {''};


%% Dienst zeeland

i = i + 1;
datatypes.grid.commonactions{i}     =  {'UCIT_getCrossSection','UCIT_IsohypseInPolygon','UCIT_plotDataInGoogleEarth','UCIT_plotDataInPolygon','UCIT_plotDifferenceMap','UCIT_plotGridOverview','UCIT_sandBalanceInPolygon'};
datatypes.grid.specificactions{i}   =  {''};

%% Dienst zeeland (test)

i = i + 1;
datatypes.grid.commonactions{i}     =  {'UCIT_getCrossSection','UCIT_IsohypseInPolygon','UCIT_plotDataInGoogleEarth','UCIT_plotDataInPolygon','UCIT_plotDifferenceMap','UCIT_plotGridOverview','UCIT_sandBalanceInPolygon'};
datatypes.grid.specificactions{i}   =  {''};

%% AHN100

i = i + 1;
datatypes.grid.commonactions{i}     =  {'UCIT_getCrossSection','UCIT_IsohypseInPolygon','UCIT_plotDataInGoogleEarth','UCIT_plotDataInPolygon','UCIT_plotDifferenceMap','UCIT_plotGridOverview','UCIT_sandBalanceInPolygon'};
datatypes.grid.specificactions{i}   =  {''};

%% AHN250

i = i + 1;
datatypes.grid.commonactions{i}     =  {'UCIT_getCrossSection','UCIT_IsohypseInPolygon','UCIT_plotDataInGoogleEarth','UCIT_plotDataInPolygon','UCIT_plotDifferenceMap','UCIT_plotGridOverview','UCIT_sandBalanceInPolygon'};
datatypes.grid.specificactions{i}   =  {''};

%% Lines data

%% Point data


