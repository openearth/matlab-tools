function varargout = xb_get_spectrum(varargin)
%XB_GET_SPECTRUM  Computes a spectrum from a timeseries
%
%   Computes a spectrum from a timeseries
%
%   FUNCTION IS A COPY OF R.T. MCCALL'S MAKESPECTRUM FUNCTION
%
%   Syntax:
%   [Snn Snnf f hrms hrmshi hrmslo] = xb_get_spectrum(ts, varargin)
%
%   Input:
%   ts        = Timeseries
%   varargin  =
%
%   Output:
%   Snn       = Energy density per frequency
%   Snnf      = Energy density per frequency (smoothed)
%   f         = Frequencies
%   hrms      = Total RMS wave height
%   hrmshi    = RMS wave height of high-frequency waves
%   hrmslo    = RMS wave height of low-frequency waves
%
%   Example
%   [Snn Snnf f hrms hrmshi hrmslo] = xb_get_spectrum(ts)
%
%   See also xb_get_wavetrans, xb_get_sedero

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
% Created: 18 Apr 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'sfreq',        1, ...
    'fsplit',       .05, ...
    'fcutoff',      1e8, ...
    'detrend',      false, ...
    'filterlength', 1, ...
    'dim',          2 ...
);

OPT = setproperty(OPT, varargin{:});

%% initalize dimensions

[d1 d2]=size(ts);

if OPT.dim == 1
    n   = length(ts(1,:));
    m   = d1;
else
    n   = length(ts(:,1));
    m   = d2;
end

%% compute spectrum

Snn     = zeros(floor(n/2),m);
Snnf    = zeros(floor(n/2),m);
hrms    = zeros(m,1);
hrmshi  = zeros(m,1);
hrmslo  = zeros(m,1);

T       = n/OPT.sfreq;
df      = 1/T;
ff      = df*[0:1:round(n/2) -1*floor(n/2)+1:1:-1];
f       = ff(1:floor(n/2));

for i = 1:m
    if OPT.dim == 1
        P   = ts(i,:); P=P(:);
    else
        P   = ts(:,i); P=P(:);
    end
    
    if OPT.detrend
        P   = detrend(P);
    end

    Q   = fft(P,[],1)/n;
    V   = 2/df*abs(Q).^2;
    
    Snn(:,i)    = squeeze(V(1:floor(n/2)));
    mininf      = max(floor(0.005/df),1);
    maxinf      = ceil(OPT.fsplit/df);
    maxhf       = min(ceil(OPT.fcutoff/df),length(Snn(:,i)));
    hrms(i)     = sqrt(8*sum(Snn(1:maxhf,i)*df));
    hrmslo(i)   = sqrt(8*sum(Snn(mininf:maxinf,i)*df));
    hrmshi(i)   = sqrt(8*sum(Snn(maxinf+1:maxhf,i)*df));
    
    for ii = 1:length(Snnf(:,i))
        Snnf(ii,i)=mean(Snn(max(1,ii-round(OPT.filterlength/2)):min(length(Snnf(:,i)),ii+round(OPT.filterlength/2)),i));
    end
end
