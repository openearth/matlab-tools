function varargout = readSTI(fname, varargin)
%READSTI  Read input file of D-Geo Stability.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = readSTI(fname, varargin)
%
%   Input: For <keyword,value> pairs call readSTI() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   readSTI
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Kees den Heijer
%
%       kees.denheijer@deltares.nl
%
%       P.O. Box 177
%       2600 MH  DELFT
%       The Netherlands
%       Rotterdamseweg 185
%       2629 HD  DELFT
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
% Created: 26 Aug 2013
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

%% read file

fid = fopen(fname,'r');
contents = fread(fid,'*char')';
fclose(fid);

%% read sections

% read all section headers
pattern = '(?<=\[)[A-Z ]*?(?=\])';
ihdr = regexp(contents, pattern, 'start');
shdr = regexp(contents, pattern, 'match');
nshdr = regexprep(shdr, '\s', '_');

[ihdr,   ix] = sort(ihdr);
shdr = shdr(ix);

D  = xs_empty();

% save header
D.header = contents(1:ihdr(1)-2);
D = xs_meta(D, [mfilename '_'], 'D-Geo Stability', abspath(fname));

substr = false(size(ihdr));
i = 0;
j2 = 0;
while i<length(ihdr)
    i = find(ihdr>j2, 1, 'first');
    if regexp(shdr{i}, '^END OF ')
        j2 = ihdr(i);
        continue
    end
    j1 = ihdr(i)+length(shdr{i})+2;
    ie = strcmp(shdr, ['END OF ' shdr{i}]);
    if ~any(ie)
        ie = i+1;
    elseif sum(ie) > 1
        ie(1:i) = false;
        ie = find(ie, 1, 'first');
    end
%     if find(ie)>i+1
%         substr(i:find(ie)) = true;
%         shdr{i}
%         Ds = xs_empty();
%         i = i+1;
%         continue
%     end
    
    j2 = ihdr(ie)-2;


    str = contents(j1:j2);
    
    funcname = [nshdr{i} '_read'];


    if ~exist(funcname)
        fprintf('"%s" skipped\n', shdr{i})
        continue
    end
    
    func = str2func(['@' funcname]);
    Ds = feval(func, str);
    D  = xs_set(D,nshdr{i},Ds);
    
%     if substr(i)
%         Ds = xs_meta(Ds, [mfilename '_'], nshdr{i}, fname);
%         j = length(Ds.data)+1;
%         Ds.data(j).name = nshdr{i};
%         Ds.data(j).value = contents(j1:j2);
%     else
%         Ds = xs_empty();
%         Ds.data(1).name = nshdr{i};
%         Ds.data(1).value = contents(j1:j2);
%     end
%     if ~substr(i+1)
%         D  = xs_set(D,nshdr{i},Ds);
%     end
    
end

% %% code
% fid = fopen(fname);
% 
% % read the entire file as characters
% % transpose so that F is a row vector
% F = fread(fid, '*char')';
% 
% fclose(fid);
% 
% splittext = cellfun(@strtrim, regexp(F, '\n', 'split'),...
%     'UniformOutput', false);
% 
% D  = xs_empty();
% 
% categories = regexp(F, '(?<=\[)[A-Z ]*?(?=\])', 'match');
% level = zeros(size(splittext));
% tmp = regexp(categories, '(?<=^END OF ).*', 'match');
% level_cats = tmp(~cellfun(@isempty, tmp));
% level_cats = unique(cellfun(@(s) s{1}, level_cats, 'UniformOutput', false));
% % fprintf('%i\t%s\n', 
% 
% for i = 1:length(level_cats)
%     catbeg = strcmp(splittext, ['[' level_cats{i} ']']);
%     catend = strcmp(splittext, ['[END OF ' level_cats{i} ']']);
%     tmp = [find(catbeg') find(catend')];
%     if ~isscalar(tmp)
%         for j = 1:size(tmp,1)
%             level(tmp(j,1)+1:tmp(j,2)-1) = level(tmp(j,1)+1:tmp(j,2)-1) + 1;
%         end
%     end
% end
varargout = {D};
% for i = 1:length(splittext)
%     fprintf('%s%s\n', blanks(level(i)*5), splittext{i})
% end

function D = VERSION_read(str)
S = dbstack();

cellstr = regexp(strtrim(str), '\n+', 'split');

D = xs_empty();
D = xs_meta(D, S(1).name, 'VERSION', '');

data = splitcellstr(cellstr, '=');
data(:,2) = num2cell(cellfun(@str2double, data(:,2)));
for i = 1:size(data,1)
    D.data(i).name = regexprep(data{i,1}, '\s', '_'); % probably hyphen will also cause problems in fieldname
    D.data(i).value = data{i,2};
end

function D = SOIL__read(str)
S = dbstack();

cellstr = regexp(strtrim(str), '\s+', 'split');
nameidx = cellfun(@isempty, strfind(cellstr, '='));
soiltype = strtrim(sprintf('%s ', cellstr{nameidx}));

D = xs_empty();
D = xs_meta(D, S(1).name, soiltype, '');

data = splitcellstr(cellstr(~nameidx), '=');
data(:,2) = num2cell(cellfun(@str2double, data(:,2)));
for i = 1:size(data,1)
    D.data(i).name = data{i,1};
    D.data(i).value = data{i,2};
end

function D = SOIL_COLLECTION_read(str)
S = dbstack();

D = xs_empty();
D = xs_meta(D, S(1).name, 'SOIL COLLECTION', '');

soilstrs = regexp(strtrim(str), '\[[A-Z ]+\]', 'split');
for i = 2:2:length(soilstrs)
    Ds = SOIL__read(soilstrs{i});
    D  = xs_set(D, Ds.type,Ds);
end

function D = ACCURACY_read(str)
D = str2double(str);

function D = POINTS_read(str)
tmp = regexp(str, '\n', 'split');
D = cell2mat(cellfun(@(s) sscanf(s, '%f'), tmp(3:end-1),...
    'uniformoutput', false))';

function D = CURVES_read(str)
S = dbstack();

D = xs_empty();
D = xs_meta(D, S(1).name, 'CURVES', '');
curvestrs = regexp(strtrim(str), '\d+\s+-\s+Curve number\s+', 'split');
for i = 2:length(curvestrs)
    Ds = CURVE__read(curvestrs{i}, i-1);
    D  = xs_set(D, Ds.type,Ds);
end

function D = CURVE__read(str, icurve)
S = dbstack();

cellstr = regexp(strtrim(str), '\s+-.*pointnumbers\s+', 'split');

D = xs_empty();
D = xs_meta(D, S(1).name, sprintf('CURVE_%i', icurve), '');

D.data(1).name = sprintf('pointnumbers');
D.data(1).value = sscanf(cellstr{2}, '%f')';

function D = GEOMETRY_DATA_read(str)
S = dbstack();

D = xs_empty();

[geomstrs, keys] = regexp(strtrim(str), '\[[A-Za-z\- ]{5,100}\]', 'split', 'match');

geomstrs = geomstrs(cellfun(@length, geomstrs) > 5);
keys = keys(1:2:end);

for i = 1:length(keys)
    funcname = [keys{i}(2:end-1) '_read'];


    if ~exist(funcname)
        fprintf('"%s" skipped\n', keys{i})
        continue
    end
    func = str2func(['@' funcname]);
    Ds = func(geomstrs{i});
    if xs_check(Ds)
        Tp = Ds.type;
    else
        Tp = keys{i}(2:end-1);
    end
    D  = xs_set(D, Tp, Ds);
                
end