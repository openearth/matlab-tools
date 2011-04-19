function xbo = xb_get_spectrum(ts, varargin)
%XB_GET_SPECTRUM  Computes a spectrum from a timeseries
%
%   Computes a spectrum from a timeseries. The result is stored in an
%   XBeach spectrum structure and can be plotted using the xb_plot_spectrum
%   function.
%
%   FUNCTION IS AN ADAPTED VERSION OF R.T. MCCALL'S MAKESPECTRUM FUNCTION
%
%   Syntax:
%   xbo = xb_get_spectrum(ts, varargin)
%
%   Input:
%   ts        = Timeseries in columns
%   varargin  = sfreq:          sample frequency
%               fsplit:         split frequency between high and low
%                               frequency waves
%               fcutoff:        cut-off frequency for high frequency waves
%               detrend:        boolean to determine whether timeseries
%                               should be linearly detrended before
%                               computation
%               filterlength:   smoothing window
%
%   Output:
%   xbo       = XBeach spectrum structure
%
%   Example
%   xbo = xb_get_spectrum(ts)
%
%   See also xb_plot_spectrum, xb_get_hydro, xb_get_morpho

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
    'detrend',      true, ...
    'filterlength', 1 ...
);

OPT = setproperty(OPT, varargin{:});

%% compute spectrum

[n m] = size(ts);

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
    P   = squeeze(ts(:,i));
    
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

%% create xbeach structure

%% create xbeach structure

xbo = xb_empty();

xbo = xb_set(xbo, 'SETTINGS', xb_set([],    ...
    'sfreq',        OPT.sfreq,              ...
    'fsplit',       OPT.fsplit,             ...
    'fcutoff',      OPT.fcutoff,            ...
    'detrend',      OPT.detrend,            ...
    'filterlength', OPT.filterlength                ));

xbo = xb_set(xbo, 'timeseries', ts      );
xbo = xb_set(xbo, 'f',          f       );
xbo = xb_set(xbo, 'Snn',        Snn     );
xbo = xb_set(xbo, 'Snn_f',      Snnf    );
xbo = xb_set(xbo, 'Hrms_hf',    hrmshi  );
xbo = xb_set(xbo, 'Hrms_lf',    hrmslo  );
xbo = xb_set(xbo, 'Hrms_t',     hrms    );

xbo = xb_meta(xbo, mfilename, 'spectrum');
