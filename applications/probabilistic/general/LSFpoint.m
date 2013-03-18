function [z x_var1] = LSFpoint(varargin)
%
%   This routine evaluates the 'x2zFunction' at the specified values of the
%   indicated stochastic variables. The other stochastic variables are set 
%   as deterministic variables having a value at which the probability of 
%   non-exceedance is 0.5.
%
%   Syntax:
%   [z] = LSFpoint(varargin)
%
%   input:
%   varargin = series of keyword-value pairs to set properties
%
%   output:
%   z-value of the point at which the limit state function is evaluated

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       hengst
%
%       Simon.denHengst@deltares.nl	
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
% Created: 25 Feb 2013
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

% defaults
OPT = struct(...
    'stochast',         struct(),... % stochast structure
    'x2zFunction',      @x2z,...  % Function to transform x to z    
    'x2zVariables',     {{}},... % additional variables to use in x2zFunction
    'method',           'matrix',... % z-function method 'matrix' (default) or 'loop'
    'NameVar',          [0],... % Names of the variables with a u value different from 0
    'UvalueVar',        [0 0]... % The u value of the variables with a u value different from 0
     );
     
% Overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin{:});

if ~iscell(OPT.NameVar);
    error('Please indicate at least one variable with a u-value different from 0');
end

if sum(ismember({OPT.stochast.Name},OPT.NameVar))==0
    error('THe indicated variables in the vector NameVar are not present in the stochast');
end

% Find index selected stochastic variables
[index] = ismember({OPT.stochast.Name},OPT.NameVar);
ind = find(index);

% Calculate value with the highest probability density of each stochastic
% variable other than the selected stochastic variables
% Transform the other stochastic variables to deterministic variables 
% having a value at which the probability of non-exceedance is 0.5.
for k=1:length(OPT.stochast)
    val(k) = feval(OPT.stochast(k).Distr,0.5,OPT.stochast(k).Params{:});
    if sum(k == ind) == 0;
        [OPT.stochast(k).Distr] = deal(@deterministic);
        [OPT.stochast(k).Params] = deal({val(k)});
    end
end

%  Construct U-vector
u = 0.5*ones(1,length(OPT.stochast)); % u=0.5 (corresponds to median)
for i = 1:length(OPT.NameVar)
    u(1,ind(i)) = OPT.UvalueVar(i);
end

% convert u to P and x
[P x] = u2Px(OPT.stochast, u);

% derive z
z = prob_zfunctioncall(OPT, OPT.stochast, x);
x_var1 = x(ind(1));