function varargout = xb_get(xb, varargin)
%XB_GET  Retrieves variables from XBeach structure
%
%   Retrieves one or more variables from XBeach structure. Data from
%   substructures can be requested by preceding the field name with the
%   structure name and a dot, for example: bcfile.Tp. You can also use
%   Funky Filter Forces (see strfilter)
%
%   Syntax:
%   varargout   = xb_get(xb, varargin)
%
%   Input:
%   xb          = XBeach structure array
%   varargin    = Names of variables to be retrieved. If omitted, all
%                 variables are returned
%                 propertyname-propertyvalue pairs:
%                 'type' : type of data requested (by default {'value'}),
%                 alternatively 'units' or 'dimensions' can be chosen, or
%                 combinations of those. Note: specify as cell array.
%
%   Output:
%   varargout   = Values of requested variables.
%
%   Example
%   [zb zs] = xb_get(xb, 'zb', 'zs')
%   Tp = xb_get(xb, 'bcfile.Tp')
%   [zb zs] = xb_get(xb, 'zb', 'zs', 'type', {'value' 'units'})
%   [d1 d2 d3] = xb_get(xb, 'drifters*')
%   d = cell(1,100); [d{:}] = xb_get(xb, 'drifters*')
%   [nx ny nt d1 d2 d3] = xb_get(xb, 'DIMS.n*', 'drifters*')
%   [H_mean u_mean v_mean] = xb_get(xb, '/_mean$')
%
%   See also xb_set, xb_show

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
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
% Created: 24 Nov 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read request

if ~xb_check(xb); error('Invalid XBeach structure'); end;

OPT = struct(...
    'type', {{'value'}});

[OPT varargin] = setproperty_filter(OPT, varargin{:});

% make sure that type is cell array
if ischar(OPT.type)
    OPT.type = {OPT.type};
end

if isempty(varargin)
    vars = {xb.data.name};
else
    vars = varargin;
end

%% read variables

varargout = cell(1,nargout);

n = 1;
for i = 1:length(vars)
    idx = strfilter({xb.data.name}, vars{i});
    if any(idx)
        for j = find(idx)
            out = struct;
            for itype = 1:length(OPT.type)
                out.(OPT.type{itype}) = xb.data(j).(OPT.type{itype});
            end
            if isscalar(OPT.type)
                out = out.(OPT.type{itype});
            end
            varargout{n} = out;
            n = n + 1;
        end
    else
        re = regexp(vars{i},'^(?<sub>.+?)\.(?<field>.+)$','names');
        if ~isempty(re)
            sub = xb_get(xb, re.sub);
            if xb_check(sub)
                out = cell(1,sum(strfilter({sub.data.name}, re.field)));
                [out{:}] = xb_get(sub, re.field, 'type', OPT.type);
                varargout{n:n+length(out)-1} = out{:};
                n = n + length(out);
            else
                n = n + 1;
            end
        else
            n = n + 1;
        end
    end
    
    if n > nargout; break; end;
end
