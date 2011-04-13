function xb_write_skilltable(measured, computed, varargin)
%XB_WRITE_SKILLTABLE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_write_skilltable(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_write_skilltable
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 13 Apr 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'file',             'skills.tex', ...
    'title',            '', ...
    'vars',             {{}} ...
);

OPT = setproperty(OPT, varargin{:});

if size(measured,2) ~= size(computed,2); error('Number of measurements not equal to number of computations'); end;

%% create table

skills = [];
labels = {};

n = 1;
for i = 2:size(measured,2)
    if ~isempty(OPT.vars) && length(OPT.vars) >= i-1
        [r2 sci relbias bss]    = xb_skill(measured(:,[1 i]), computed(:,[1 i]), 'var', OPT.vars{i-1});
        labels{n}               = ['$' OPT.vars{i-1} '$'];
    else
        [r2 sci relbias bss]    = xb_skill(measured([1 i],:), computed([1 i],:));
        labels{n}               = '';
    end
    
    skills(n,:) = [r2 sci relbias bss];
    
    n = n + 1;
end

matrix2latex(skills, 'filename', OPT.file, ...
    'caption',  OPT.title, ...
    'rowlabel', labels, ...
    'collabel', {'$R^2$','Sci','Rel. bias','BSS'}, ...
    'format',	{'%s', '%4.2f', '%4.2f', '%4.2f', '%4.2f'});

