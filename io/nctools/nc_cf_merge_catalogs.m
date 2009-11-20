function nc_cf_merge_catalogs(varargin)
%NC_CF_MERGE_CATALOGS   test script for
%
%See also: NC_CF_DIRECTORY2CATALOG, NC_CF2CATALOG


%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Mark van Koningsveld
%
%       m.vankoningsveld@tudelft.nl
%
%       Hydraulic Engineering Section
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 17 Aug 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% get catalog
OPT = struct(...
    'base', [] ...           % base dir
    );

% overrule default settings by property pairs, given in varargin
OPT = setProperty(OPT, varargin{:});

filenames = findAllFiles( ...
    'pattern_excl', {[filesep,'.svn']}, ...   % description of input argument 1
    'pattern_incl', 'catalog.mat', ...        % description of input argument 2
    'basepath', OPT.base ...                  % description of input argument 3
    );

catalog = load(filenames{1});
cat_fieldnames = fieldnames(catalog);
for i = 2:length(filenames)
    catalog_add = load(filenames{i}); %#ok<NASGU>
    for j = 1:length(cat_fieldnames)
        if eval(['ischar(catalog.' cat_fieldnames{j} ')'])      % for the fields that are chars
            eval(['catalog.' cat_fieldnames{j} ' = char([cellstr(catalog.' cat_fieldnames{j} '); catalog_add.' cat_fieldnames{j} ']);']);
        elseif eval(['isfloat(catalog.' cat_fieldnames{j} ')']) % for the fields that are floats
            eval(['catalog.' cat_fieldnames{j} ' = [catalog.' cat_fieldnames{j} '; catalog_add.' cat_fieldnames{j} '];']);
        end
    end
end
struct2nc([OPT.base filesep 'main_catalog.nc'],catalog)

