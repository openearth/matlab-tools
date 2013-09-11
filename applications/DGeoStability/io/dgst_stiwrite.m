function varargout = dgst_stiwrite(fname, D, varargin)
%DGST_STIWRITE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = dgst_stiwrite(varargin)
%
%   Input: For <keyword,value> pairs call dgst_stiwrite() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   dgst_stiwrite
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

txt = sprintf('%s', D.header);

for i = 1:length(D.data)
    txt = sprintf('%s%s', txt, writeblock(D.data(i)));
    if any(strcmp(D.data(i).name, {'VERSION', 'SOIL_COLLECTION', 'GEOMETRY_DATA'}))
        txt = sprintf('%s\r\n', txt);
    end
end
txt = sprintf('%s[END OF INPUT FILE]\r\n', txt);

% txt = regexprep(txt, '\r\r', '\r');

%% write file
fid = fopen(fname, 'w');
fprintf(fid, '%s', txt);
fclose(fid)

%%%%%%%%%%% private functions
%%%% general helper functions
function hd = type2header(str)
hd = regexprep(str, '_', ' ');
hd = regexprep(hd, '(?<= CO) (?=ORDINATES$)', '-');
hd = regexprep(hd, '(?<=^SIGMA) (?=TAU CURVES$)', '-');

function txt = nameisvalue(Ds, varargin)
OPT = struct(...
    'header', '',...
    'namecol', 1,...
    'valcol', 2,...
    'delimiter', '=',...
    'format', '%g',...
    'regexprep', {{}});

OPT = setproperty(OPT, varargin);
data = repmat({''}, 2, length(Ds.data));
data(OPT.namecol,:) = {Ds.data.name};
data(OPT.valcol,:) = {Ds.data.value};
for i = 1:2:length(OPT.regexprep)
    data(OPT.namecol,:) = regexprep(data(OPT.namecol,:), OPT.regexprep{i:i+1});
end
data(OPT.namecol,:) = regexprep(data(OPT.namecol,:), '_', ' ');
if ischar(OPT.format)
    fmt = {'%s', '%s'};
    fmt{OPT.valcol} = OPT.format;
    format = sprintf(['%s' OPT.delimiter '%s\r\n'], fmt{:});
elseif iscell(OPT.format)
    fmt = repmat({'%s'}, 3, length(Ds.data));
    fmt(2,:) = {OPT.delimiter};
    if OPT.valcol == 2
        fmt(3,:) = OPT.format;
    else
        fmt(OPT.valcol,:) = OPT.format;
    end
    format = sprintf(['%s%s%s\r\n'], fmt{:});
elseif isstruct(OPT.format)
    if isfield(OPT.format, 'default_')
        defformat = OPT.format.default_;
    else
        defformat = '';
    end
    formatcell = repmat({defformat}, 1, length(Ds.data));
    fnames = fieldnames(OPT.format);
    for i = 1:length(fnames)
        idx = ~cellfun(@isempty, regexp(fnames{i}, data(OPT.namecol,:), 'once'));
        if any(idx)
            formatcell{idx} = OPT.format.(fnames{i});
        end
    end
    if isfield(OPT.format, 'regexp_')
        for i = 1:2:length(OPT.format.regexp_)
            idx = ~cellfun(@isempty, regexp(data(OPT.namecol,:), OPT.format.regexp_{i}, 'once'));
            if any(idx)
                formatcell(idx) = OPT.format.regexp_(i+1);
            end
        end
    end
    OPT.format = formatcell;
    txt = nameisvalue(Ds, OPT);
    return
    %format = sprintf(['%%s' OPT.delimiter '%s\r\n'], formatcell{:});
end
txt = sprintf(format, data{:});

function txt = writeblock(Ds, varargin)

txt = sprintf('[%s]', type2header(Ds.name));
funcname = [Ds.name '_write'];
if exist(funcname)
    func = str2func(funcname);
    stxt = feval(func, Ds.value);
elseif ischar(Ds.value)
%     stxt = sprintf('%s\n', strtrim(Ds.value));
    cellstr = regexp(Ds.value, '\r\n', 'split');
    idx = ~cellfun(@(s) isempty(strtrim(s)), cellstr);
    stxt = sprintf('%s\r\n', cellstr{idx});
    if ~strcmp(Ds.name , {'LAYERLOADS', 'RUN_IDENTIFICATION_TITLES'})
        %stxt = regexprep(stxt, '\r\n$', '');
    elseif strcmp(Ds.name , 'LAYERLOADS')
        stxt = sprintf('%s\r\n', stxt);
    end
end
noendkeys = {'RUN_IDENTIFICATION_TITLES', 'MSEEPNET', 'UNIT_WEIGHT_WATER',...
    'DEGREE_OF_CONSOLIDATION', 'degree_Temporary_loads', 'degree_earth_quake',...
    'CIRCLES', 'SPENCER_SLIP_DATA', 'SPENCER_SLIP_DATA_2', 'SPENCER_SLIP_INTERVAL',...
    'LINE_LOADS', 'UNIFORM_LOADS_', 'EARTH_QUAKE', 'MINIMAL_REQUIRED_CIRCLE_DEPTH',...
    'START_VALUE_SAFETY_FACTOR', 'REFERENCE_LEVEL_CU', 'LIFT_SLIP_DATA',...
    'EXTERNAL_WATER_LEVELS', 'MODEL_FACTOR', 'NEWZONE_PLOT_DATA',...
    'REQUESTED_CIRCLE_SLICES', 'REQUESTED_LIFT_SLICES', 'REQUESTED_SPENCER_SLICES'};
if strcmp(Ds.name, 'Slip_Circle_Selection')
    endstr = sprintf('[End of %s]', type2header(Ds.name));
elseif ~any(strcmp(Ds.name, noendkeys))
    endstr = sprintf('[END OF %s]', type2header(Ds.name));
else
    endstr = '';
end
newlinekeys0 = {'GEOMETRY_DATA'};
newlinekeys2 = {'ACCURACY', 'POINTS', 'CURVES', 'BOUNDARIES',...
    'USE_PROBABILISTIC_DEFAULTS_BOUNDARIES', 'STDV_BOUNDARIES', 'DISTRIBUTION_BOUNDARIES',...
    'PIEZO_LINES', 'PHREATIC_LINE', 'WORLD_CO_ORDINATES', 'LAYERS', 'LAYERLOADS'};
if any(strcmp(Ds.name, newlinekeys0))
    endstr = sprintf('%s', endstr);
elseif any(strcmp(Ds.name, newlinekeys2))
    endstr = sprintf('%s\r\n\r\n', endstr);
else
    endstr = sprintf('%s\r\n', endstr);
end
txt = sprintf('%s\r\n%s%s', txt, stxt, endstr);

function txt = list_write(Ds, varargin)
OPT = struct(...
    'feature', '');
OPT = setproperty(OPT, varargin);
if strcmpi('curve', OPT.feature)
    feature_plur = [OPT.feature 's'];
elseif strcmpi('boundary', OPT.feature)
    feature_plur = [OPT.feature(1:end-1) 'ies'];
end
txt = sprintf('%4i - Number of %s -\r\n', length(Ds.data), lower(feature_plur));
for i = 1:length(Ds.data)
    ifeature = str2double(regexprep(Ds.data(i).name, '^\D+_', ''));
    txt = sprintf('%s%6i - %s number\r\n', txt, ifeature, OPT.feature);
    if strcmpi('curve', OPT.feature)
        txt = sprintf('%s%8i - number of points on %s, next line(s) are pointnumbers\r\n', txt, length(Ds.data(i).value), lower(OPT.feature));
    elseif strcmpi('boundary', OPT.feature)
        txt = sprintf('%s%8i - number of curves on %s, next line(s) are curvenumbers\r\n', txt, length(Ds.data(i).value), lower(OPT.feature));
    end
    stxt = sprintf('%6i', Ds.data(i).value);
    txt = sprintf('%s    %s\r\n', txt, stxt);
end

function txt = probabilistic_boundary_list_write(Ds, varargin)

OPT = struct(...
    'format', '%g');
OPT = setproperty(OPT, varargin);
txth = sprintf('%4i - Number of boundaries -\r\n', length(Ds));
txtv = sprintf([OPT.format '\r\n'], Ds);
txt = sprintf('%s%s', txth, txtv);


%%%% header specific functions
function txt = VERSION_write(Ds)
txt = nameisvalue(Ds,...
    'regexprep', {'D_Geo', 'D-Geo'});

function txt = SOIL_COLLECTION_write(Ds)
n = length(Ds.data);
txt = sprintf('%5i = number of items\r\n', n);
for i = 1:n
    Dss = Ds.data(i);
    Dss.name = regexprep(Dss.name, '[_\d]', '');
    txt = sprintf('%s%s', txt, writeblock(Dss));
end

function txt = SOIL_write(Ds)
txt = sprintf('%s\r\n%s', regexprep(Ds.type, '_', ' '), nameisvalue(Ds,...
    'format', struct('default_', '%g',...
    'SoilColor', '%i',...
    'SoilPc', '%.2E',...
    'SoilExcessPorePressure', '%.2f',...
    'SoilPorePressureFactor', '%.2f',...
    'SoilCohesion', '%.2f',...
    'SoilPhi', '%.2f',...
    'SoilDilatancy', '%.2f',...
    'StrengthIncreaseExponent', '%.2f',...
    'SoilPOP', '%.2f',...
    'SoilRheologicalCoefficient', '%.2f',...
    'SoilCorrelationCPhi', '%.2f',...
    'SoilRRatio', '%.7f',...
    'regexp_', {{...
    '^SoilStd.*', '%.2f',...
    '^SoilCu.*', '%.2f',...
    '[xy]CoorSoilPc$', '%.3f',...
    '^SoilGam.*', '%.2f',...
    '^SoilRatioCuPc.*', '%.2f',...
    '^SoilDesign.*', '%.2f',...
    '^SoilHorFluct.*', '%.2f'}}...
    )));
% the following keywords appear twice in the SOIL definition
repkeys = {'SoilDistCu', 'SoilDistCuTop', 'SoilDistCuGradient'};
for i = 1:length(repkeys)
    txt = sprintf('%s%s=%g\r\n', txt, repkeys{i},  xs_get(Ds, repkeys{i}));
end

function txt = GEOMETRY_DATA_write(Ds)
txt = '';
for i = 1:length(Ds.data)
    Dss = Ds.data(i);
    txt = sprintf('%s%s', txt, writeblock(Dss));
end

function txt = ACCURACY_write(Ds)
txt = sprintf('%14.4f\r\n', Ds);

function txt = POINTS_write(Ds)
txth = sprintf('%7i  - Number of geometry points -\r\n', size(Ds,1));
txtd = sprintf('%8i%15.3f%15.3f%15.3f\r\n', Ds');
txt = sprintf('%s', txth, txtd);

function txt = CURVES_write(Ds)
txt = list_write(Ds,...
    'feature', 'Curve');

function txt = BOUNDARIES_write(Ds)
txt = list_write(Ds,...
    'feature', 'Boundary');

function txt = USE_PROBABILISTIC_DEFAULTS_BOUNDARIES_write(Ds)
txt = probabilistic_boundary_list_write(Ds,...
    'format', '%3i');

function txt = MODEL_write(Ds)
regexprep = {Ds.data(~[Ds.data.value]).name};
regexprep = [regexprep(:)'; cellfun(@(s) [s ' off'], regexprep(:)', 'uniformoutput', false)];
idx = ~strcmpi(regexprep(1,:), 'local_measurements');
regexprep = regexprep(:,idx);
txt = nameisvalue(Ds,...
    'namecol', 2,...
    'valcol', 1,...
    'delimiter', ' : ',...
    'format', repmat({'%3i'}, size(Ds.data)),...
    'regexprep', regexprep(:));