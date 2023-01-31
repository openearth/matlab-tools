function bathymetry = ddb_readTiledBathymetries(bathydir,varargin)
%DDB_READTILEDBATHYMETRIES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readTiledBathymetries(handles)
%
%   Input:
%   handles =
%
%   Output:
%   handles =
%
%   Example
%   ddb_readTiledBathymetries
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

if isempty(varargin)
    requested_datasets={'all'};
else
    requested_datasets=varargin{1};
end

%% When enabled on OpenDAP
% Check for updates on OpenDAP and add data to structure
localdir = bathydir;
url = 'https://opendap.deltares.nl/static/deltares/delftdashboard/bathymetry/bathymetry.xml';
xmlfile = 'bathymetry.xml';
bathymetry = ddb_getXmlData(localdir,url,xmlfile);
bathymetry.dir=bathydir;

if ~strcmpi(requested_datasets{1},'all')
    % First filter datasets
    n=0;
    for j=1:length(bathymetry.dataset)
        for kk=1:length(requested_datasets)
            if ~isempty(strmatch(lower(bathymetry.dataset(j).name),lower(requested_datasets{kk}),'exact'))
                n=n+1;
                bathy0.dataset(n)=bathymetry.dataset(j);
            end
        end
    end
    bathy0.dir=bathymetry.dir;
    bathymetry=bathy0;
end

% Add specific fields to structure

names = '';
longNames = '';

for ii=1:length(bathymetry.dataset)
    
%    bathymetry.dataset(ii).useCache = 1;
%    bathymetry.dataset(ii).edit     = 0;
    
    if isfield(bathymetry.dataset(ii),'useCache')
        if ~isempty(bathymetry.dataset(ii).useCache)
            bathymetry.dataset(ii).useCache = str2double(bathymetry.dataset(ii).useCache);
        else    
            bathymetry.dataset(ii).useCache = 1;
        end
    else    
        bathymetry.dataset(ii).useCache = 1;
    end
    if isfield(bathymetry.dataset(ii),'edit')
        if ~isempty(bathymetry.dataset(ii).edit)
            bathymetry.dataset(ii).edit = str2double(bathymetry.dataset(ii).edit);
        else
            bathymetry.dataset(ii).edit = 0;
        end
    else
        bathymetry.dataset(ii).edit = 0;
    end
    
    names{ii}= bathymetry.dataset(ii).name;
    longNames{ii} = '';

    try
        longNames{ii} = bathymetry.dataset(ii).longName;
    end

end
bathymetry.datasets = names;
bathymetry.longNames = longNames;
%bathymetry.nrDatasets = length(bathymetry.(fld{1}));
bathymetry.nrDatasets = length(bathymetry.dataset);
