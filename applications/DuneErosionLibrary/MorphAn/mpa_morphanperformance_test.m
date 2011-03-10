function mpa_morphanperformance_test()
% MORPHANPERFORMANCE_TEST  Performance comparison of the various DUROS calculations
%
% Compares the Maltab duros code with two ways of calling MorphAn C# code 
% in terms of calculation speed.
%
%
%   See also DUROS mpa_durosplus mpa_durosplusfast

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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
% Created: 10 Mar 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Test Category
MTestCategory.Performance;

clc;
xInitial = [-250 -24.375 5.625 55.725 230.625 1950]';
zInitial = [15 15 3 0 -3 -14.4625]';
D50 = 225e-6;
WL_t= 5;
Hsig_t= 9;
Tp_t= 12;
Bend = 0;

mpa_loadcsharp;
n = 10;

a = tic;
for i = 1:n
    r = DUROS(xInitial, zInitial, D50, WL_t, Hsig_t, Tp_t,'Bend',Bend);
end
matlabTime = toc(a);
disp(['Matlab duros : ' num2str(matlabTime)]);

b = tic;
for i = 1:n
    r = mpa_durosplus(xInitial, zInitial, D50, WL_t, Hsig_t, Tp_t,'Bend',Bend);
end
morphAnTime = toc(b);
disp(['MorphAn duros : ' num2str(morphAnTime) ' / *' num2str(matlabTime/morphAnTime)]);

c = tic;
for i = 1:n
    r = mpa_durosplusfast(xInitial, zInitial, D50, WL_t, Hsig_t, Tp_t,Bend);
end
morphAnTimeFast = toc(c);
disp(['MorphAn duros fast : ' num2str(morphAnTimeFast) ' / *' num2str(matlabTime / morphAnTimeFast)]);

assert(morphAnTimeFast < matlabTime \ 10,'Fast MorphAn should be at least 10 times faster than Matlab');
