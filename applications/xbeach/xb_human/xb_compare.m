function [identical messages] = xb_compare(xb1, xb2, varargin)
%XB_COMPARE  Compares to XBeach structures
%
%   Compares to XBeach structures and returns a boolean indicating if the
%   two structures are identical and messages on differences, if they are
%   not.
%
%   Syntax:
%   [identical messages] = xb_compare(xb1, xb2, varargin)
%
%   Input:
%   xb1       = First XBeach structure
%   xb2       = Second XBeach structure
%   varargin  = none
%
%   Output:
%   identical = Boolean indicating if the two are identical
%   messages  = Messages describing the differences
%
%   Example
%   identical = xb_compare(xb1, xb2)
%
%   See also xb_set, xb_empty, xb_read_input

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
% Created: 01 Mar 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

if ~xb_check(xb1); error('Invalid XBeach structure #1'); end;
if ~xb_check(xb2); error('Invalid XBeach structure #2'); end;

OPT = struct( ...
    'skip_meta', {{'date', 'data'}}, ...
    'skip_data', {{}} ...
);

OPT = setproperty(OPT, varargin{:});

messages = {};

%% compare meta data

f = unique(cat(1,fieldnames(xb1),fieldnames(xb2)));
for i = 1:length(f)
    if ~ismember(f{i}, OPT.skip_meta)
        if isfield(xb1.data, f{i}) && isfield(xb2.data, f{i})
            if ~compvar(xb1.(f{i}), xb2.(f{i}))
                messages = [messages{:} {['Meta field "' f{i} '" is different']}];
            end
        elseif ~isfield(xb1, f{i})
            messages = [messages{:} {['Meta field "' f{i} '" is missing in the first structure']}];
        elseif ~isfield(xb2, f{i})
            messages = [messages{:} {['Meta field "' f{i} '" is missing in the second structure']}];
        end
    end
end

%% compare data

f = unique(cat(2,{xb1.data.name},xb2.data.name));
for i = 1:length(f)
    if ~ismember(f{i}, OPT.skip_data)
        if ismember(f{i}, {xb1.data.name}) && ismember(f{i}, {xb2.data.name})
            v1 = xb_get(xb1, f{i});
            v2 = xb_get(xb2, f{i});
            
            if xb_check(v1) && xb_check(v2)
                [id m] = xb_compare(v1, v2);
                if ~id
                    messages = [messages{:} {['Data field "' f{i} '" is different']}];
                    messages = [messages{:} m];
                end
            elseif ~compvar(v1, v2)
                messages = [messages{:} {['Data field "' f{i} '" is different']}];
            end
        elseif ~ismember(f{i}, {xb1.data.name})
            messages = [messages{:} {['Data field "' f{i} '" is missing in the first structure']}];
        elseif ~ismember(f{i}, {xb2.data.name})
            messages = [messages{:} {['Data field "' f{i} '" is missing in the second structure']}];
        end
    end
end

%% check if structures are identical

if isempty(messages)
    identical = true;
else
    identical = false;
end