function z = prob_vdMeer_example_x2z(x, varnames, Resistance, varargin)
%PROB_VDMEER_EXAMPLE_X2Z  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = prob_vdMeer_example_x2z(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   prob_vdMeer_example_x2z
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
%       The Netherlands
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 03 Sep 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% retrieve calculation values
for i = 1:size(x,2)
    eval([varnames{i} ' = [' num2str(x(:,i)') ']'';'])
end

%%
g = 9.81;                               %[m/s2]
for i = 1:size(x,1)
    Delta = (RhoS(i) - RhoW(i)) / RhoW(i);    % [-] relative density
    Ksi = TanAlfa(i)/sqrt(Steep(i));      % [-] Iribarren number
    z(i,:) = Cpl(i)*P(i)^0.18*(S(i)/sqrt(N(i)))^0.2*Ksi^(-0.5)-H(i)/Delta/D(i); %[-] vdMeer
end