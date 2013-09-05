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
    txt = sprintf('%s[%s]', txt, type2header(D.data(i).name));
    funcname = [D.data(i).name '_write'];
    if exist(funcname)
        func = str2func(funcname);
        stxt = feval(func, D.data(i));
    elseif ischar(D.data(i).value)
        stxt = D.data(i).value;
    else
        stxt = '';
    end
    txt = sprintf('%s\n%s[END OF %s]\n', txt, stxt, type2header(D.data(i).name));
end

%% write file
fid = fopen(fname, 'w');
fprintf(fid, '%s', txt);
fclose(fid)

%%%%%%%%%%% private functions
%%%% general helper functions
function hd = type2header(str)
hd = regexprep(str, '_', ' ');

function txt = nameisvalue(Ds, varargin)
OPT = struct(...
    'header', '',...
    'namecol', 1,...
    'valcol', 2,...
    'delimiter', '=',...
    'format', '%g',...
    'regexprep', {{}});

OPT = setproperty(OPT, varargin);
data = repmat({''}, 2, length(Ds.value.data));
data(OPT.namecol,:) = {Ds.value.data.name};
data(OPT.valcol,:) = {Ds.value.data.value};
data(OPT.namecol,:) = regexprep(data(OPT.namecol,:), OPT.regexprep{:});
data(OPT.namecol,:) = regexprep(data(OPT.namecol,:), '_', ' ');
txt = sprintf(['%s=' OPT.format '\n'], data{:});

%%%% header specific functions
function txt = VERSION_write(Ds)
txt = nameisvalue(Ds,...
    'regexprep', {'D_Geo', 'D-Geo'});

function txt = SOIL_COLLECTION_write(Ds)
txt = sprintf('%5i = number of items\n', length(Ds.value.data));