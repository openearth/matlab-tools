function xbo = xb_get_hydro(xb, varargin)
%XB_GET_HYDRO  Compute hydrodynamic parameters from XBeach output structure
%
%   Compute hydrodynamic parameters like RMS wave heights over a
%   cross-section split in low and high freqnecy waves. The same is done
%   for orbital velocities and mean velocities. Also the water level setup
%   is computed, if possible. The results are stored in an XBeach
%   hydrodynamics structure and can be plotted with xb_plot_hydro.
%
%   Syntax:
%   xbo = xb_get_hydro(xb, varargin)
%
%   Input:
%   xb        = XBeach output structure
%   varargin  = fsplit:     cut-off frequency for high frequency waves
%
%   Output:
%   xbo       = XBeach hydrodynamics structure
%
%   Example
%   xbo = xb_get_hydro(xb)
%   xbo = xb_get_hydro(xb, 'fsplit', .05)
%
%   See also xb_plot_hydro, xb_get_morpho, xb_get_spectrum

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

if ~xb_check(xb); error('Invalid XBeach structure'); end;

OPT = struct( ...
    'fsplit',          .1 ...
);

OPT = setproperty(OPT, varargin{:});

%% initialize input

xb      = xb_get_transect(xb);

dt      = mean(diff(xb_get(xb, 'DIMS.globaltime_DATA')));

f       = {xb.data.name};
re      = regexp(f,'^(.+)_mean$','tokens');
idx     = find(~cellfun(@isempty, re));

for i = idx
    xb  = xb_rename(xb, f{i}, re{i}{1}{1});
end

if ~isempty(idx)
    dt  = mean(diff(xb_get(xb, 'DIMS.meantime_DATA')));
end

%% initialize output

zb_i    = 0;
zb_f    = 0;
Hrms_hf = 0;
Hrms_lf = 0;
Hrms_t  = 0;
s       = 0;
urms_hf = 0;
urms_lf = 0;
urms_t  = 0;
umean   = 0;
vmean   = 0;

%% compute wave transformation characteristics

% determine bathymetry
if xb_exist(xb, 'zb')
    zb      = xb_get(xb,'zb');
    zb_i    = zb(1,1,:);
    zb_f    = zb(end,1,:);
end
    
% split HF and LF waves
if xb_exist(xb, 'zs')
    if xb_exist(xb, 'zb')
        [hf lf] = filterhjb(xb_get(xb,'zs')-xb_get(xb,'zb'),OPT.fsplit,dt,false);
    else
        [hf lf] = filterhjb(xb_get(xb,'zs'),OPT.fsplit,dt,false);
    end
    
    Hrms_hf = sqrt(8).*std(hf,1);
    Hrms_lf = sqrt(8).*std(lf,1);
end
if xb_exist(xb, 'u')
    [hf lf] = filterhjb(xb_get(xb,'u'),OPT.fsplit,dt,false);
    
    urms_hf = std(hf,1);
    urms_lf = std(lf,1);
end

% compute HF waves
if xb_exist(xb, 'H')
    Hrms_hf = sqrt(mean(xb_get(xb,'H').^2,1)+Hrms_hf.^2);
    if xb_exist(xb, 'zs')
        Hrms_t = sqrt(Hrms_lf.^2+Hrms_hf.^2);
    end
end

% compute setup
if xb_exist(xb, 'zs')
    if xb_exist(xb, 'zb') || xb_exist(xb, 'u')
        zs = xb_get(xb,'zs');
        
        if xb_exist(xb, 'zb');  zb = xb_get(xb,'zb');   k = zs(end,1,:)-zb(end,1,:)>0.0001; end;
        if xb_exist(xb, 'u');   u = xb_get(xb,'u');     k = abs(u(end,1,:))>0.0001;         end;
        
        s = max(0,mean(zs-mean(zs(:,1,1),1),1));
        s(:,:,~k) = 0;
    end
end
    
% compute HF orbital velocity
if xb_exist(xb, 'urms')
    urms_hf = sqrt(mean(xb_get(xb,'urms').^2,1)+urms_hf.^2);
    if xb_exist(xb, 'u')
        urms_t = sqrt(urms_lf.^2+urms_hf.^2);
    end
end

% compute mean velocity
if xb_exist(xb, 'ue')
    umean = mean(xb_get(xb,'ue'),1);
end

if xb_exist(xb, 've')
    vmean = mean(xb_get(xb,'ve'),1);
end

%% create xbeach structure

xbo = xb_empty();

xbo = xb_set(xbo, 'SETTINGS', xb_set([], ...
    'fsplit',  OPT.fsplit                     ));

xbo = xb_set(xbo, 'DIMS', xb_get(xb, 'DIMS'));

if ~isscalar(zb_i);     xbo = xb_set(xbo, 'zb_i',       squeeze(zb_i));      end;
if ~isscalar(zb_f);     xbo = xb_set(xbo, 'zb_f',       squeeze(zb_f));      end;
if ~isscalar(Hrms_hf);  xbo = xb_set(xbo, 'Hrms_hf',    squeeze(Hrms_hf));   end;
if ~isscalar(Hrms_lf);  xbo = xb_set(xbo, 'Hrms_lf',    squeeze(Hrms_lf));   end;
if ~isscalar(Hrms_t);   xbo = xb_set(xbo, 'Hrms_t',     squeeze(Hrms_t));    end;
if ~isscalar(s);        xbo = xb_set(xbo, 's',          squeeze(s));         end;
if ~isscalar(urms_hf);  xbo = xb_set(xbo, 'urms_hf',    squeeze(urms_hf));   end;
if ~isscalar(urms_lf);  xbo = xb_set(xbo, 'urms_lf',    squeeze(urms_lf));   end;
if ~isscalar(urms_t);   xbo = xb_set(xbo, 'urms_t',     squeeze(urms_t));    end;
if ~isscalar(umean);    xbo = xb_set(xbo, 'umean',      squeeze(umean));     end;
if ~isscalar(vmean);    xbo = xb_set(xbo, 'vmean',      squeeze(vmean));     end;

xbo = xb_meta(xbo, mfilename, 'hydrodynamics');
