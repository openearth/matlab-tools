function varargout = dbf_get(varargin)
%DBF_GET  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = dbf_get(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   dbf_get
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
%       Netherlands
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
% Created: 27 Jul 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read input

varargout = {};

if ~isempty(varargin)
    
    if isstruct(varargin{1})
        
        if isfield(varargin{1}, 'data') && isfield(varargin{1}, 'headers')
        
            data    = varargin{1}.data;
            headers = varargin{1}.headers;
            vars    = varargin(2:end);
            
        else
            error('Unknown input structure');
        end
        
    elseif length(varargin) > 1
        
        data    = varargin{1};
        headers = varargin{2};
        vars    = varargin(3:end);
        
    else
        error('Not enough input parameters');
    end
    
    for i = 1:length(vars)
        
        idx = find(strfilter(headers, vars{i}));
    
        for j = 1:length(idx)

            varargout = [varargout {data(:,idx(j))}];

        end
    end
    
end