function varargout = dgst_stiread(fname, varargin)
%DGST_STIREAD  Read input file of D-Geo Stability.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = dgst_stiread(varargin)
%
%   Input: For <keyword,value> pairs call dgst_stiread() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   dgst_stiread
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@deltares.nl
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 05 Sep 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
OPT = struct();
% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
%% code

%% read file

fid = fopen(fname,'r');
contents = fread(fid,'*char')';
fclose(fid);

[datastr, keys] = regexpi(strtrim(contents), '\[[a-z0-9\- ]{4,100}\]',...
    'split', 'match');

% datastr = datastr(~cellfun(@(s) isempty(strtrim(s)), datastr));

D = xs_empty();
D.header = datastr{1};
D.file = getfilename(fname);

% endid = ~cellfun(@isempty, regexpi(keys, '[end of '));

for i = 1:length(keys)
    if regexpi(keys{i}, '[end of')
        continue
    end
    Tp = header2type(keys{i});
    funcname = sprintf('%s_read', upper(Tp));
    if exist(funcname)
        func = str2func(funcname);
    else
        func = @fallback_read;
    end
    D = feval(func, datastr{i+1}, Tp, D);
end

varargout = {D};

%%%%%%%%%%% private functions
%%%% general helper functions
function Tp = header2type(str)
str = regexprep(str, '[\[\]\.]', '');
str = regexprep(str, '\(.*\)', '');
Tp = strtrim(regexprep(strtrim(str), '[- ]', '_'));

function Tp = funname2type()
S = dbstack();
Tp = regexprep(S(2).name, '_+read$', '');

function varargout = getfilename(varargin)
persistent fname
if nargin == 1
    fname = abspath(varargin{1});
end
varargout = {fname};

function fun = getfunname(varargin)
S = dbstack();
fun = S(2).name;

function D = nameisvalue(str, varargin)
OPT = struct(...
    'skiplines', 0,...
    'namecol', 1,...
    'valcol', 2,...
    'delimiter', '=',...
    'format', '%g',...
    'regexprep', {{}});

OPT = setproperty(OPT, varargin);

D = xs_empty();
D = xs_meta(D, getfunname(), funname2type(), getfilename());

cellstr = regexp(strtrim(str), '\n', 'split');
cellstr = cellstr(1+OPT.skiplines:end);
cellstr = regexp(cellstr, OPT.delimiter, 'split');

for i = 1:length(cellstr)
    if ~isempty(OPT.format)
        val = sscanf(cellstr{i}{OPT.valcol}, OPT.format);
    else
        val = strtrim(cellstr{i}{OPT.valcol});
    end
    D = xs_set(D, header2type(cellstr{i}{OPT.namecol}), val);
end

function D = fallback_read(str, key, D)
D = xs_set(D, header2type(key), str);

%%%% header specific functions
function D = VERSION_read(str, key, D)
Ds = nameisvalue(str);
D = xs_set(D, key, Ds);

function D = SOIL_COLLECTION_read(str, key, D)
Ds = xs_empty();
Ds = xs_meta(Ds, getfunname(), funname2type(), getfilename());
D = xs_set(D, key, Ds);

function D = SOIL_read(str, key, D)
Dss = nameisvalue(str, 'skiplines', 1);
tmp = regexp(str, '(?<=^\s*)\D+(?=\n)', 'match'); % first line of text block
Dss.type = header2type(tmp{1}); % soil type
Ds = xs_get(D, 'SOIL_COLLECTION');
Ds = xs_set(Ds, sprintf('%s_%02i', key, length(Ds.data)+1), Dss);
D = xs_set(D, 'SOIL_COLLECTION', Ds);

function D = GEOMETRY_DATA_read(str, key, D)
Ds = xs_empty();
Ds = xs_meta(Ds, getfunname(), key, getfilename());
D = xs_set(D, key, Ds);

function D = ACCURACY_read(str, key, D)
Ds = xs_get(D, 'GEOMETRY_DATA');
Ds = xs_set(Ds, key, str);
D = xs_set(D, 'GEOMETRY_DATA', Ds);

function D = POINTS_read(str, key, D)
Ds = xs_get(D, 'GEOMETRY_DATA');
Ds = xs_set(Ds, key, str);
D = xs_set(D, 'GEOMETRY_DATA', Ds);

function D = CURVES_read(str, key, D)
Ds = xs_get(D, 'GEOMETRY_DATA');
Ds = xs_set(Ds, key, str);
D = xs_set(D, 'GEOMETRY_DATA', Ds);

function D = BOUNDARIES_read(str, key, D)
Ds = xs_get(D, 'GEOMETRY_DATA');
Ds = xs_set(Ds, key, str);
D = xs_set(D, 'GEOMETRY_DATA', Ds);

function D = USE_PROBABILISTIC_DEFAULTS_BOUNDARIES_read(str, key, D)
Ds = xs_get(D, 'GEOMETRY_DATA');
Ds = xs_set(Ds, key, str);
D = xs_set(D, 'GEOMETRY_DATA', Ds);

function D = STDV_BOUNDARIES_read(str, key, D)
Ds = xs_get(D, 'GEOMETRY_DATA');
Ds = xs_set(Ds, key, str);
D = xs_set(D, 'GEOMETRY_DATA', Ds);

function D = DISTRIBUTION_BOUNDARIES_read(str, key, D)
Ds = xs_get(D, 'GEOMETRY_DATA');
Ds = xs_set(Ds, key, str);
D = xs_set(D, 'GEOMETRY_DATA', Ds);

function D = PIEZO_LINES_read(str, key, D)
Ds = xs_get(D, 'GEOMETRY_DATA');
Ds = xs_set(Ds, key, str);
D = xs_set(D, 'GEOMETRY_DATA', Ds);

function D = PHREATIC_LINE_read(str, key, D)
Ds = xs_get(D, 'GEOMETRY_DATA');
Ds = xs_set(Ds, key, str);
D = xs_set(D, 'GEOMETRY_DATA', Ds);

function D = WORLD_CO_ORDINATES_read(str, key, D)
Ds = xs_get(D, 'GEOMETRY_DATA');
Ds = xs_set(Ds, key, str);
D = xs_set(D, 'GEOMETRY_DATA', Ds);

function D = LAYERS_read(str, key, D)
Ds = xs_get(D, 'GEOMETRY_DATA');
Ds = xs_set(Ds, key, str);
D = xs_set(D, 'GEOMETRY_DATA', Ds);

function D = LAYERLOADS_read(str, key, D)
Ds = xs_get(D, 'GEOMETRY_DATA');
Ds = xs_set(Ds, key, str);
D = xs_set(D, 'GEOMETRY_DATA', Ds);

function D = RUN_IDENTIFICATION_TITLES_read(str, key, D)
D = xs_set(D, key, str);

function D = MODEL_read(str, key, D)
D = xs_set(D, key, str);

function D = MSEEPNET_read(str, key, D)
D = xs_set(D, key, str);

function D = UNIT_WEIGHT_WATER_read(str, key, D)
D = xs_set(D, key, str);

function D = DEGREE_OF_CONSOLIDATION_read(str, key, D)
D = xs_set(D, key, str);

function D = degree_Temporary_loads_read(str, key, D)
D = xs_set(D, key, str);

function D = degree_earth_quake_read(str, key, D)
D = xs_set(D, key, str);

function D = CIRCLES_read(str, key, D)
D = xs_set(D, key, str);

function D = SPENCER_SLIP_DATA_read(str, key, D)
D = xs_set(D, key, str);

function D = SPENCER_SLIP_DATA_2_read(str, key, D)
D = xs_set(D, key, str);

function D = SPENCER_SLIP_INTERVAL_read(str, key, D)
D = xs_set(D, key, str);

function D = LINE_LOADS_read(str, key, D)
D = xs_set(D, key, str);

function D = UNIFORM_LOADS_read(str, key, D)
D = xs_set(D, key, str);

function D = TREE_ON_SLOPE_read(str, key, D)
D = xs_set(D, key, str);

function D = EARTH_QUAKE_read(str, key, D)
D = xs_set(D, key, str);

function D = SIGMA_TAU_CURVES_read(str, key, D)
D = xs_set(D, key, str);

function D = BOND_STRESS_DIAGRAMS_read(str, key, D)
D = xs_set(D, key, str);

function D = MINIMAL_REQUIRED_CIRCLE_DEPTH_read(str, key, D)
D = xs_set(D, key, str);

function D = Slip_Circle_Selection_read(str, key, D)
D = xs_set(D, key, str);

function D = START_VALUE_SAFETY_FACTOR_read(str, key, D)
D = xs_set(D, key, str);

function D = REFERENCE_LEVEL_CU_read(str, key, D)
D = xs_set(D, key, str);

function D = LIFT_SLIP_DATA_read(str, key, D)
D = xs_set(D, key, str);

function D = EXTERNAL_WATER_LEVELS_read(str, key, D)
D = xs_set(D, key, str);

function D = MODEL_FACTOR_read(str, key, D)
D = xs_set(D, key, str);

function D = CALCULATION_OPTIONS_read(str, key, D)
D = xs_set(D, key, str);

function D = PROBABILISTIC_DEFAULTS_read(str, key, D)
D = xs_set(D, key, str);

function D = NEWZONE_PLOT_DATA_read(str, key, D)
D = xs_set(D, key, str);

function D = HORIZONTAL_BALANCE_read(str, key, D)
D = xs_set(D, key, str);

function D = REQUESTED_CIRCLE_SLICES_read(str, key, D)
D = xs_set(D, key, str);

function D = REQUESTED_LIFT_SLICES_read(str, key, D)
D = xs_set(D, key, str);

function D = REQUESTED_SPENCER_SLICES_read(str, key, D)
D = xs_set(D, key, str);

function D = SOIL_RESISTANCE_read(str, key, D)
D = xs_set(D, key, str);

function D = GENETIC_ALGORITHM_OPTIONS_BISHOP_read(str, key, D)
D = xs_set(D, key, str);

function D = GENETIC_ALGORITHM_OPTIONS_LIFTVAN_read(str, key, D)
D = xs_set(D, key, str);

function D = GENETIC_ALGORITHM_OPTIONS_SPENCER_read(str, key, D)
D = xs_set(D, key, str);

function D = NAIL_TYPE_DEFAULTS_read(str, key, D)
D = xs_set(D, key, str);