function xb_plot_morpho(xb, varargin)
%XB_PLOT_MORPHO  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_plot_morpho(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_plot_morpho
%
%   See also 

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

figure; hold on;

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
    if ~has_m || ~isempty(OPT.dz);      addplot(x,                  dz(end,:),              '-',    'k',    'computed'  );  end;
    
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
    if ~has_m || ~isempty(OPT.ero);     addplot(t,                  xb_get(xb, 'ero'),      '-',    'k',    'computed'  );  end;
    
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
    if ~has_m || ~isempty(OPT.R);       addplot(t,                  R-R1,                   '-',    'k',    'computed'  );  end;
    
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
