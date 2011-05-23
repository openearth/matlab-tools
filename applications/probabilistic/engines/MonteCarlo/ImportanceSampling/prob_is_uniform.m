function [P P_corr] = prob_is_uniform(P, varargin)
%PROB_IS_UNIFORM  Importance sampling method based on uniform distribution
%
%   Importance sampling method based on uniform distribution.
%
%   Syntax:
%   [P P_corr] = prob_is_uniform(P, varargin)
%
%   Input:
%   P         = Vector with random draws for importance sampling stochast
%   varargin  = #1: lower frequency boundary of uniform distribution
%               #2: upper frequency boundary of uniform distribution
%
%   Output:
%   P         = Modified vector with random draws
%   P_corr    = Correction factor for probability of failure computation
%
%   Example
%   [P P_corr] = prob_is_uniform(P, f1, f2)
%
%   See also prob_is, prob_is_factor, prob_is_incvariance,
%            prob_is_exponential

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

%% read options

if ~isempty(varargin) && length(varargin)>1
    f1 = min([varargin{1:2}]);
    f2 = max([varargin{1:2}]);
else
    f1 = 0;
    f2 = Inf;
end

%% importance sampling

Pb      = exp(-[f2 f1]);
ub      = norm_inv(Pb,0,1);

u       = ub(1)+P*diff(ub);
P       = norm_cdf(u,0,1);

%% correction factor

P_corr  = diff(ub)*norm_pdf(u,0,1);
