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
%   varargin  = fcutoff:    cut-off frequency for high frequency waves
%
%   Output:
%   xbo       = XBeach hydrodynamics structure
%
%   Example
%   xbo = xb_get_hydro(xb)
%   xbo = xb_get_hydro(xb, 'fcutoff', .05)
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
    'fcutoff',          .1 ...
);

OPT = setproperty(OPT, varargin{:});

%% compute wave transformation characteristics

dt      = 1/xb_get(xb, 'DIMS.globaltime');
j       = ceil(xb_get(xb, 'DIMS.globaly')/2);

% initialize output
zb_i    = 0;
zb_f    = 0;
Hrms_hf = 0;
Hrms_lf = 0;
Hrms_t  = 0;
s       = 0;
urms_hf = 0;
urms_lf = 0;
umean   = 0;

if xb_exist(xb, 'ue') && ~xb_exist(xb, 'u'); xb = xb_rename(xb, 'ue', 'u'); end;

% determine bathymetry
if xb_exist(xb, 'zb')
    zb = xb_get(xb,'zb');
    zb_i = squeeze(zb(1,j,:));
    zb_f = squeeze(zb(end,j,:));
end
    
% split HF and LF waves
if xb_exist(xb, 'zs')
    [Hrms_hf Hrms_lf] = filterhjb(xb_get(xb,'zs'),OPT.fcutoff,dt,false);
end

% compute HF waves
if xb_exist(xb, 'H')
    Hrms_hf = sqrt(mean(xb_get(xb,'H').^2,1)+8*std(Hrms_hf,[],1).^2);
    Hrms_hf = squeeze(Hrms_hf(1,j,:));
end

% compute LF waves
if xb_exist(xb, 'zs')
    Hrms_lf = sqrt(8).*std(Hrms_lf,[],1);
    Hrms_lf = squeeze(Hrms_lf(1,j,:));
    
    if xb_exist(xb, 'H')
        Hrms_t = sqrt(Hrms_lf.^2+Hrms_hf);
    end
    
    if xb_exist(xb, 'zb') || xb_exist(xb, 'u')
        zs = xb_get(xb,'zs');
        
        if xb_exist(xb, 'zb');  zb = xb_get(xb,'zb');   k = zs(end,j,:)-zb(end,j,:)>0.0001; end;
        if xb_exist(xb, 'u');   u = xb_get(xb,'u');     k = abs(u(end,j,:))>0.0001;         end;
        
        s = max(0,mean(zs-mean(zs(:,j,1),1),1));
        s(:,:,~k) = 0;
        s = squeeze(s(1,j,:));
    end
end
    
% compute orbital velocity
if xb_exist(xb, 'urms')
    urms_t = sqrt(mean(xb_get(xb,'urms').^2,1));
    urms_t = squeeze(urms_t(1,j,:));

    if xb_exist(xb, 'u')
        [urms_hf urms_lf] = filterhjb(xb_get(xb,'u'),OPT.fcutoff,dt,false);
        urms_hf = 0;
        
        urms_lf = std(urms_lf,[],1);
        urms_lf = squeeze(urms_lf(1,j,:));
    end
end

% compute mean velocity
if xb_exist(xb, 'u')
    umean = mean(xb_get(xb,'u'),1);
    umean = squeeze(umean(1,j,:));
end

%% create xbeach structure

xbo = xb_empty();

xbo = xb_set(xbo, 'SETTINGS', xb_set([], ...
    'fcutoff',  OPT.fcutoff                     ));

xbo = xb_set(xbo, 'DIMS', xb_get(xb, 'DIMS'));

if ~isscalar(zb_i);     xbo = xb_set(xbo, 'zb_i',       zb_i);      end;
if ~isscalar(zb_f);     xbo = xb_set(xbo, 'zb_f',       zb_f);      end;
if ~isscalar(Hrms_hf);  xbo = xb_set(xbo, 'Hrms_hf',    Hrms_hf);   end;
if ~isscalar(Hrms_lf);  xbo = xb_set(xbo, 'Hrms_lf',    Hrms_lf);   end;
if ~isscalar(Hrms_t);   xbo = xb_set(xbo, 'Hrms_t',     Hrms_t);    end;
if ~isscalar(s);        xbo = xb_set(xbo, 's',          s);         end;
if ~isscalar(urms_hf);  xbo = xb_set(xbo, 'urms_hf',    urms_hf);   end;
if ~isscalar(urms_lf);  xbo = xb_set(xbo, 'urms_lf',    urms_lf);   end;
if ~isscalar(urms_t);   xbo = xb_set(xbo, 'urms_t',     urms_t);    end;
if ~isscalar(umean);    xbo = xb_set(xbo, 'umean',      umean);     end;

xbo = xb_meta(xbo, mfilename, 'hydrodynamics');
