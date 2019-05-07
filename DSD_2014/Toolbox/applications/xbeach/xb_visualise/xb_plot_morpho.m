function xb_plot_morpho(xb, varargin)
%XB_PLOT_MORPHO  Create uniform morphology plots
%
%   Create uniform morphology plots from an XBeach morphology
%   structure. Depending on the amount of information provided, different
%   plots over the x-axis and time are plotted. Measurements are provided
%   in a nx2 matrix in which the first column is the x-axis and the second
%   the data axis.
%
%   Syntax:
%   fh = xb_plot_morpho(xb, varargin)
%
%   Input:
%   xb        = XBeach output structure
%   varargin  = handles:    Figure handle or list of axes handles
%               dz:         Measured bed level change
%               sed:        Measured sedimentation volume in time
%               ero:        Measured erosion volume in time
%               R:          Measured retreat distance
%               Q:          Measured separation point between erosion and
%                           accretion
%               P:          Measured delimitation of active zone
%               units_dist: Units used for distance axes
%               units_vol:  Units used for volume axis
%               units_time: Units used for time axis
%               showall:    Show all data available instead of only show
%                           data matched by measurements
%
%   Output:
%   none
%
%   Example
%   xb_plot_morpho(xb)
%   xb_plot_morpho(xb, 'dz', dz, 'sed', sed)
%
%   See also xb_plot_profile, xb_plot_hydro, xb_get_morpho

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

% $Id: xb_plot_morpho.m 4147 2014-10-31 10:12:42Z bieman $
% $Date: 2014-10-31 11:12:42 +0100 (ven, 31 ott 2014) $
% $Author: bieman $
% $Revision: 4147 $
% $HeadURL: https://svn.oss.deltares.nl/repos/xbeach/Courses/DSD_2014/Toolbox/applications/xbeach/xb_visualise/xb_plot_morpho.m $
% $Keywords: $

%% read options

if ~xs_check(xb); error('Invalid XBeach structure'); end;

OPT = struct( ...
    'handles',          [], ...
    'dz',               [], ...
    'sed',              [], ...
    'ero',              [], ...
    'R',                [], ...
    'Q',                [], ...
    'P',                [], ...
    'title',            '', ...
    'units_dist',       'm', ...
    'units_vol',        'm^3/m', ...
    'units_time',       'h', ...
    'showall',          false ...
);

OPT = setproperty(OPT, varargin{:});

%% plot

% determine dimensions
x = xs_get(xb, 'DIMS.globalx_DATA');
t = xs_get(xb, 'DIMS.globaltime_DATA')/3600;
j = ceil(xs_get(xb, 'DIMS.globaly')/2);
x = squeeze(x(j,:));

% determine available data
has_m           = ~isempty(OPT.dz) || ~isempty(OPT.ero) || ~isempty(OPT.R);

if OPT.showall; has_m = false; end;

% compute number of subplots
sp = [0 0 0];
if (has_m && ~isempty(OPT.dz)) || (~has_m && xs_exist(xb, 'dz'));   sp(1) = 1;  end;
if (has_m && ~isempty(OPT.ero)) || (~has_m && xs_exist(xb, 'ero')); sp(2) = 1;  end;
if (has_m && ~isempty(OPT.R)) || (~has_m && xs_exist(xb, 'R'));     sp(3) = 1;  end;

% create handles
n   = sum(sp);
ax  = xb_get_handles(n, 'handles', OPT.handles);
si  = 1;

% subplot 1
if sp(1)
        
    axes(ax(si)); si = si + 1; hold on;
    
    title('bed level change');
    xlabel(['distance [' OPT.units_dist ']']);
    ylabel(['height [' OPT.units_dist ']']);
    
    % plot measurements
    if ~isempty(OPT.dz);                addplot(OPT.dz(:,1),        OPT.dz(:,2),            'o',    'k',    'measured'  );  end;

    % plot computation
    dz = xs_get(xb, 'dz');
    if ~has_m || ~isempty(OPT.dz);      addplot(x,                  dz(end,:)',             '-',    'r',    'computed'  );  end;
    
    legend('show', 'Location', 'SouthWest');
end

% subplot 2
if sp(2)
        
    axes(ax(si)); si = si + 1; hold on;
    
    title('erosion volume');
    xlabel(['time [' OPT.units_time ']']);
    ylabel(['volume [' OPT.units_vol ']']);
    
    % plot measurements
    if ~isempty(OPT.ero);               addplot(OPT.ero(:,1),       OPT.ero(:,2),           'o',    'k',    'measured'  );  end;

    % plot computation
    if ~has_m || ~isempty(OPT.ero);     addplot(t,                  xs_get(xb, 'ero'),      '-',    'g',    'computed'  );  end;
    
    legend('show', 'Location', 'SouthEast');
end

% subplot 3
if sp(3)
        
    axes(ax(si)); si = si + 1; hold on;
    
    title('retreat distance');
    xlabel(['time [' OPT.units_time ']']);
    ylabel(['distance [' OPT.units_dist ']']);
    
    % plot measurements
    if ~isempty(OPT.R);                 addplot(OPT.R(:,1),         OPT.R(:,2),             'o',    'k',    'measured'  );  end;

    % plot computation
    R   = xs_get(xb, 'R');
    R1  = R(find(~isnan(R),1,'first'));
    if ~has_m || ~isempty(OPT.R);       addplot(t,                  R-R1,                   '-',    'b',    'computed'  );  end;
    
    if sp(2); linkaxes(ax(si-2:si-1), 'x'); end;
    
    legend('show', 'Location', 'SouthEast');
end

% add labels
for i = 1:sum(sp)
    axes(ax(i));
    
    box on;
    grid on;
end

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
