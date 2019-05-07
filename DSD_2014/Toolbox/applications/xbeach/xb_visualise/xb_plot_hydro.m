function xb_plot_hydro(xb, varargin)
%XB_PLOT_HYDRO  Create uniform wave transformation plots
%
%   Create uniform wave transformation plots from an XBeach hydrodynamics
%   structure. Depending on the amount of information provided, different
%   plots over the x-axis are plotted. Measurements are provided in a nx2
%   matrix in which the first column is the x-axis and the second the data
%   axis.
%
%   Syntax:
%   fh = xb_plot_hydro(xb, varargin)
%
%   Input:
%   xb        = XBeach output structure
%   varargin  = handles:    Figure handle or list of axes handles
%               zb:         Measured final profile
%               Hrms_hf:    Measured high frequency wave height
%               Hrms_lf:    Measured low frequency wave height
%               Hrms_t:     Measured total wave height
%               s:          Measured water level setup
%               urms_hf     Measured high frequency oribtal velocity
%               urms_lf     Measured low frequency oribtal velocity
%               urms_t      Measured total oribtal velocity
%               umean       Measured mean cross-shore flow velocity
%               vmean       Measured mean longshore flow velocity
%               units_dist: Units used for x- and z-axis
%               units_vel:  Units used for secondary z-axis
%               showall:    Show all data available instead of only show
%                           data matched by measurements
%
%   Output:
%   none
%
%   Example
%   xb_plot_hydro(xb)
%   xb_plot_hydro(xb, 'zb', zb, 'Hrms_t', H)
%
%   See also xb_plot_profile, xb_plot_morpho, xb_get_hydro

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

% $Id: xb_plot_hydro.m 4147 2014-10-31 10:12:42Z bieman $
% $Date: 2014-10-31 11:12:42 +0100 (ven, 31 ott 2014) $
% $Author: bieman $
% $Revision: 4147 $
% $HeadURL: https://svn.oss.deltares.nl/repos/xbeach/Courses/DSD_2014/Toolbox/applications/xbeach/xb_visualise/xb_plot_hydro.m $
% $Keywords: $

%% read options

if ~xs_check(xb); error('Invalid XBeach structure'); end;

OPT = struct( ...
    'handles',          [], ...
    'zb',               [], ...
    'zs',               [], ...
    'Hrms_hf',          [], ...
    'Hrms_lf',          [], ...
    'Hrms_t',           [], ...
    's',                [], ...
    'urms_hf',          [], ...
    'urms_lf',          [], ...
    'urms_t',           [], ...
    'umean',            [], ...
    'vmean',            [], ...
    'units_dist',       'm', ...
    'units_vel',        'm/s', ...
    'H_lims',           [], ...
    'u_lims',           [], ...
    'showall',          false ...
);

OPT = setproperty(OPT, varargin{:});

%% compute derived data

if ~isempty(OPT.Hrms_hf) && ~isempty(OPT.Hrms_lf) && isempty(OPT.Hrms_t)
    x           = unique([OPT.Hrms_hf(:,1);OPT.Hrms_lf(:,1)]);
    y1          = interp1(OPT.Hrms_hf(:,1),OPT.Hrms_hf(:,2),x);
    y2          = interp1(OPT.Hrms_lf(:,1),OPT.Hrms_lf(:,2),x);
    OPT.Hrms_t  = [x sqrt(y1.^2+y2.^2)];
end

if ~isempty(OPT.zs) && isempty(OPT.s)
    OPT.s       = OPT.zs;
    OPT.s(:,2)  = OPT.s(:,2)-OPT.s(1,2);
end

%% plot

% determine dimensions
x = xs_get(xb, 'DIMS.globalx_DATA');
j = ceil(xs_get(xb, 'DIMS.globaly')/2);
x = squeeze(x(j,:));

% determine available data
has_bathy_m     = ~isempty(OPT.zb);
has_waves_m     = ~isempty(OPT.Hrms_hf) || ~isempty(OPT.Hrms_lf) || ~isempty(OPT.Hrms_t) || ~isempty(OPT.s);
has_flow_m      = ~isempty(OPT.urms_hf) || ~isempty(OPT.urms_lf) || ~isempty(OPT.urms_t) || ~isempty(OPT.umean) || ~isempty(OPT.vmean);
has_m           = has_bathy_m || has_waves_m || has_flow_m;

has_bathy_c     = xs_exist(xb, 'zb_*');
has_waves_c     = xs_exist(xb, 'Hrms_*') || xs_exist(xb, 's');
has_flow_c      = xs_exist(xb, 'urms_*') || xs_exist(xb, 'umean') || xs_exist(xb, 'vmean');

if OPT.showall; has_m = false; end;

% compute number of subplots
sp = [0 0];
if (has_m && (has_bathy_m || has_waves_m)) || (~has_m && (has_bathy_c || has_waves_c)); sp(1) = 1;  end;
if (has_m && has_flow_m ) || (~has_m && has_flow_c);                                    sp(2) = 1;  end;

% create handles
n   = sum(sp);
ax  = xb_get_handles(n, 'handles', OPT.handles);
si  = 1;

% subplot 1
if sp(1)
    
    axes(ax(si)); if ~isempty(OPT.H_lims); axis(ax(si),OPT.H_lims); end; si = si + 1; hold on;
    
    title('wave heights and water levels');
    ylabel(['height [' OPT.units_dist ']']);
    
    % plot measurements
    if ~isempty(OPT.zb);                addplot(OPT.zb(:,1),        OPT.zb(:,2),            '.',    'k',    'bathymetry (final,measured)'       );  end;
    if ~isempty(OPT.Hrms_hf);           addplot(OPT.Hrms_hf(:,1),   OPT.Hrms_hf(:,2),       '^',    'k',    'wave height (HF,measured)'         );  end;
    if ~isempty(OPT.Hrms_lf);           addplot(OPT.Hrms_lf(:,1),   OPT.Hrms_lf(:,2),       'v',    'k',    'wave height (LF,measured)'         );  end;
    if ~isempty(OPT.Hrms_t);            addplot(OPT.Hrms_t(:,1),    OPT.Hrms_t(:,2),        's',    'k',    'wave height (measured)'            );  end;
    if ~isempty(OPT.s);                 addplot(OPT.s(:,1),         OPT.s(:,2),             'o',    'k',    'setup (measured)'                  );  end;

    % plot bathymetry
    if ~has_m || ~isempty(OPT.zb);      addplot(x,                  xs_get(xb, 'zb_i'),     ':',    'k',    'bathymetry (initial)'              );  end;
    if ~has_m || ~isempty(OPT.zb);      addplot(x,                  xs_get(xb, 'zb_f'),     '-',    'k',    'bathymetry (final)'                );  end;

    % plot waves
    if ~has_m || ~isempty(OPT.Hrms_hf); addplot(x,                  xs_get(xb, 'Hrms_hf'),  '--',   'r',    'wave height (HF)'                  );  end;
    if ~has_m || ~isempty(OPT.Hrms_lf); addplot(x,                  xs_get(xb, 'Hrms_lf'),  ':',    'r',    'wave height (LF)'                  );  end;
    if ~has_m || ~isempty(OPT.Hrms_t);  addplot(x,                  xs_get(xb, 'Hrms_t'),   '-',    'r',    'wave height'                       );  end;
    
    % plot setup
    if ~has_m || ~isempty(OPT.s);       addplot(x,                  xs_get(xb, 's'),        '-.',   'b',    'setup'                             );  end;
end

% subplot 2
if sp(2)
    
    axes(ax(si)); if ~isempty(OPT.H_lims); axis(ax(si),OPT.H_lims); end; si = si + 1; hold on;
    
    title('flow velocities');
    ylabel(['velocity [' OPT.units_vel ']']);
    
    % plot measurements
    if ~isempty(OPT.urms_hf);           addplot(OPT.urms_hf(:,1),   OPT.urms_hf(:,2),       '^',    'k',    'flow velocity (RMS,HF,measured)'   );  end;
    if ~isempty(OPT.urms_lf);           addplot(OPT.urms_lf(:,1),   OPT.urms_lf(:,2),       'v',    'k',    'flow velocity (RMS,LF,measured)'   );  end;
    if ~isempty(OPT.urms_t);            addplot(OPT.urms_t(:,1),    OPT.urms_t(:,2),        's',    'k',    'flow velocity (RMS,measured)'      );  end;
    if ~isempty(OPT.umean);             addplot(OPT.umean(:,1),     OPT.umean(:,2),         'o',    'k',    'flow velocity (u,mean,measured)'   );  end;
    if ~isempty(OPT.vmean);             addplot(OPT.vmean(:,1),     OPT.vmean(:,2),         '.',    'k',    'flow velocity (v,mean,measured)'   );  end;
    
    % plot orbital velocity
    if ~has_m || ~isempty(OPT.urms_hf); addplot(x,                  xs_get(xb, 'urms_hf'),  '--',  'g',    'flow velocity (RMS,HF)'             );  end;
    if ~has_m || ~isempty(OPT.urms_lf); addplot(x,                  xs_get(xb, 'urms_lf'),  ':',   'g',    'flow velocity (RMS,LF)'             );  end;
    if ~has_m || ~isempty(OPT.urms_t);  addplot(x,                  xs_get(xb, 'urms_t'),   '-',   'g',    'flow velocity (RMS)'                );  end;
    
    % plot mean velocity
    if ~has_m || ~isempty(OPT.umean);   addplot(x,                  xs_get(xb, 'umean'),    '-.',  'g',    'flow velocity (u,mean)'             );  end;
    if ~has_m || ~isempty(OPT.vmean);   addplot(x,                  xs_get(xb, 'vmean'),    '-.',  'b',    'flow velocity (v,mean)'             );  end;
end

% add labels
for i = 1:n
    axes(ax(i));

    xlabel(['distance [' OPT.units_dist ']']);

    legend
    legend('show', 'Location', 'NorthWest');

    box on;
    grid on;
end

linkaxes(ax, 'x');

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function addplot(x, data, type, color, name)
    if ~isempty(data);
        if length(x) < size(data,1)
            data = data(1:length(x),:);
        elseif length(x) > size(data,1)
            x = linspace(min(x),max(x),size(data,1));
        end
        
        plot(x, data, type, ...
            'Color', color, ...
            'LineWidth', 2, ...
            'DisplayName', name);
    end
end

end
