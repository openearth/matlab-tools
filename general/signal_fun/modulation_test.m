function modulation_test()
% MODULATION_TEST   Test script for modulation
%  
% More detailed description of the test goes here.
%
%
%   See also modulation

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
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
% Created: 23 Jun 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTestCategory.Integration;

%% settings
time       = datenum(1990,5,linspace(0,31,5000)); % [days]
freq       = [1.9323  2       ];                  % [cyc/day]
omega      =  2*pi*freq;                          % [rad/day]
amplitudes = [0.67238 0.16315];                   % [m]
phases     = [108.02  174    ];                   % [deg]
names      = {'M2','S2'};

%% t_predic requires freq in 1/hr
f        = 1;tidecon = [amplitudes(f) eps phases(f) eps];
M2       = t_predic(time,{'M2'},freq(f)./24,tidecon);

f        = 2;tidecon = [amplitudes(f) eps phases(f) eps];
S2       = t_predic(time,{'S2'},freq(f)./24,tidecon);

[FIT]    = harmanal(time,M2+S2,'omega',omega,'screenoutput',0);

%% get envelope
envelope = modulation(omega,FIT.hamplitudes,FIT.hphases,time);

%% plot
plot    (time,envelope,'r','displayname','envelope');
hold     on
plot    (time,M2','g'    ,'displayname','M2');
plot    (time,S2,'b'     ,'displayname','S2');
plot    (time,M2 + S2,'k','displayname','M2 + S2');
timeaxis(datenum(1990,5,1:2:32),'fmt','dd-mmm');
grid     on
legend   show
xlabel  (num2str(unique(year(xlim))))
ylabel  ('waterlevel [m]')
