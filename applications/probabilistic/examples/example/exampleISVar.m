function sampling = exampleISVar(varargin)
%EXAMPLEISVAR  Creates a sample importance sampling structure
%
%   Creates a sample importance sampling structure.
%
%   Syntax:
%   sampling = exampleISVar(varargin)
%
%   Input:
%   varargin  = active:     Logical vector indicating on which default
%                           variables importance sampling should be enabled
%
%   Output:
%   sampling  = Importance sampling structure array
%
%   Example
%   sampling = exampleISVar
%
%   See also MC, prob_is

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
% Created: 19 May 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% create struct

sampling = struct(              ...
    'Name', {                   ...
        'Accuracy'              ...
        'D50'                   ...
        'Duration'              ...
        'WL_t'                  ...
        'Hsig_t'                ...
        'Tp_t'                  ...
    },                          ...
    'Method', {                 ...
        @prob_is_factor   ...
        @prob_is_factor   ...
        @prob_is_factor   ...
        @prob_is_uniform  ...
        @prob_is_factor   ...
        @prob_is_factor   ...
    },                          ...
    'Params', {                 ...
        {1}                     ...
        {1}                     ...
        {1}                     ...
        {0 Inf}                 ...
        {1}                     ...
        {1}                     ...
    }                           ...
);

%% read options

OPT = struct(...
    'active', true(size(sampling)));

OPT = setproperty(OPT, varargin{:});

%% de-activate samplings

for i = find(~OPT.active)
    sampling(i).Method  = [];
    sampling(i).Params  = {};
end
