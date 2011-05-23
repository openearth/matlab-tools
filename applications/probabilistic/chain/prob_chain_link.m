function chain = prob_chain_link(chain, last_chain, last_output, varargin)
%PROB_CHAIN_LINK  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = prob_chain_link(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   prob_chain_link
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
% Created: 23 May 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

%% analyze last output

if ~isstruct(last_output) || isempty(last_output) || isempty(fieldnames(last_output)); return; end;
if ~isstruct(last_chain)  || isempty(last_chain)  || isempty(fieldnames(last_chain));  return; end;
if ~isstruct(chain)       || isempty(chain)       || isempty(fieldnames(chain));       return; end;

if isfield(last_output, 'Output')
    last_output = last_output.Output;
end

u_closest = last_output.u(abs(last_output.z)==min(abs(last_output.z)),:);

%% link chain

% switch methods
switch chain.Method
    case 'FORM'
        chain.Params = set_optval('startU',u_closest,chain.Params{:});
    case 'MC'
        IS = [];
        for i = 1:length(chain.Stochast)
            IS(i)           = exampleISVar;
            IS(i).Name      = chain.Stochast.Name;
            IS(i).Method    = @prob_is_normal;
            IS(i).Params    = {u_closest(i) 1};
        end

        chain.Params = set_optval('IS',IS,chain.Params{:});
end