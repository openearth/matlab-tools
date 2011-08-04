function z = Pf2z(samples, Pf, varargin)
%PF2Z  Converts failure probabilities to z-values based on Monte Carlo result
%
%   Returns z-values corresponding to one or more failure probabilites
%   based on a set of Monte Carlo samples.
%
%   Syntax:
%   z = Pf2z(samples, Pf, varargin)
%
%   Input:
%   samples   = list of z-values from Monte Carlo routine
%   Pf        = list of failure probabilities
%   varargin  = increment:  initial increment used in search routine
%               resistance: original resistance used in computation of
%                           z-values
%               correction: list of correction factors corresponding to
%                           z-values, for example returned by importance
%                           sampling routine
%
%   Output:
%   z         = list of z-values corresponding to failure probabilities
%
%   Example
%   z = Pf2z(samples, Pf)
%
%   See also MC

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
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
% Created: 03 Aug 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% settings

OPT = struct(...
    'increment',    10,         ...
    'resistance',   0,          ...
    'correction',   []          ...
);

OPT = setproperty(OPT, varargin{:});

%% initialisation

samples = OPT.resistance - samples;

if isempty(OPT.correction)
    OPT.correction = ones(size(samples));
end

N = length(samples);

%% search z value

z  = nan(size(Pf));

for i = 1:length(Pf)
    
    ll = -Inf;
    ul = Inf;
    
    Pfl = nan;
    
    while true
        
        if ~isinf(ll)
            if ~isinf(ul)
                R = mean([ll ul]);
            else
                R = ll + OPT.increment;
            end
        else
            if ~isinf(ul)
                R = ul - OPT.increment;
            else
                R = 0;
            end
        end
        
        Pfi = sum((R-samples<0).*OPT.correction)./N;
        
        if Pfl == Pfi
            z(i) = R;
            break;
        elseif Pfi > Pf(i)
            ll = R;
        elseif Pfi < Pf(i)
            ul = R;
        end
        
        Pfl = Pfi;
        
    end
end
