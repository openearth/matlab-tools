function fh = xb_plot_morpho(xb, varargin)
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
%   varargin  = dz:         Measured bed level change
%               sed:        Measured sedimentation volume in time
%               ero:        Measured erosion volume in time
%               R:          Measured retreat distance
%               Q:          Measured separation point between erosion and
%                           accretion
%               P:          Measured delimitation of active zone
%               units:      Units used for x- and z-axis
%               units2:     Units used for secondary z-axis
%               units3:     Units used for tertiary z-axis
%
%   Output:
%   fh        = Figure handle
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

if ~xb_check(xb); error('Invalid XBeach structure'); end;

OPT = struct( ...
    'dz',               [], ...
    'sed',              [], ...
    'ero',              [], ...
    'R',                [], ...
    'Q',                [], ...
    'P',                [], ...
    'title',            '', ...
    'units',            'm', ...
    'units2',           'm^3/m', ...
    'units3',           'h' ...
);

OPT = setproperty(OPT, varargin{:});

%% plot

fh = figure; hold on;

% determine dimensions
x = xb_get(xb, 'DIMS.globalx_DATA');
t = xb_get(xb, 'DIMS.globaltime_DATA')/3600;
j = ceil(xb_get(xb, 'DIMS.globaly')/2);
x = squeeze(x(j,:));

% determine available data
has_m           = ~isempty(OPT.dz) || ~isempty(OPT.ero) || ~isempty(OPT.R);

% compute number of subplots
sp = [0 0 0];
if (has_m && ~isempty(OPT.dz)) || (~has_m && xb_exist(xb, 'dz'));   sp(1) = 1;  end;
if (has_m && ~isempty(OPT.ero)) || (~has_m && xb_exist(xb, 'ero')); sp(2) = 1;  end;
if (has_m && ~isempty(OPT.R)) || (~has_m && xb_exist(xb, 'R'));     sp(3) = 1;  end;

n   = sum(sp);
ax  = nan(1,n);
si  = 1;

% subplot 1
if sp(1)
        
    ax(si) = subplot(n,1,si); si = si + 1; hold on;
    
    title('bed level change');
    xlabel(['distance [' OPT.units ']']);
    ylabel(['height [' OPT.units ']']);
    
    % plot measurements
    if ~isempty(OPT.dz);                addplot(OPT.dz(:,1),        OPT.dz(:,2),            'o',    'k',    'measured'  );  end;

    % plot computation
    dz = xb_get(xb, 'dz');
    if ~has_m || ~isempty(OPT.dz);      addplot(x,                  dz(end,:),              '-',    'r',    'computed'  );  end;
    
    legend('show', 'Location', 'SouthWest');
end

% subplot 2
if sp(2)
        
    ax(si) = subplot(n,1,si); si = si + 1; hold on;
    
    title('erosion volume');
    xlabel(['time [' OPT.units3 ']']);
    ylabel(['volume [' OPT.units2 ']']);
    
    % plot measurements
    if ~isempty(OPT.ero);               addplot(OPT.ero(:,1),       OPT.ero(:,2),           'o',    'k',    'measured'  );  end;

    % plot computation
    if ~has_m || ~isempty(OPT.ero);     addplot(t,                  xb_get(xb, 'ero'),      '-',    'g',    'computed'  );  end;
    
    legend('show', 'Location', 'SouthEast');
end

% subplot 3
if sp(3)
        
    ax(si) = subplot(n,1,si); si = si + 1; hold on;
    
    title('retreat distance');
    xlabel(['time [' OPT.units3 ']']);
    ylabel(['distance [' OPT.units ']']);
    
    % plot measurements
    if ~isempty(OPT.R);                 addplot(OPT.R(:,1),         OPT.R(:,2),             'o',    'k',    'measured'  );  end;

    % plot computation
    R   = xb_get(xb, 'R');
    R1  = R(find(~isnan(R),1,'first'));
    if ~has_m || ~isempty(OPT.R);       addplot(t,                  R-R1,                   '-',    'b',    'computed'  );  end;
    
    if sp(2); linkaxes(ax(si-2:si-1), 'x'); end;
    
    legend('show', 'Location', 'SouthEast');
end

% add labels
for i = 1:sum(sp)
    subplot(n,1,i);
    
    box on;
    grid on;
end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function addplot(x, data, type, color, name)
    if ~isempty(data);
        plot(x, data, type, ...
            'Color', color, ...
            'LineWidth', 1, ...
            'DisplayName', name);
    end
end

end
