function fh = xb_plot_profile(xb, varargin)
%XB_PLOT_PROFILE  Create uniform profile plots
%
%   Create uniform profile plots using standardized coloring per source.
%   Automatically computes Brier Skill Scores and makes sure the dune is
%   located right on the figure. Profiles are supplied in the form of
%   matrices from which the first column contains x-coordinates and
%   successive columns contain z-values.
%
%   Syntax:
%   xb_plot_profile(xb, varargin)
%
%   Input:
%   xb       =  XBeach output structure
%   varargin =  measured:       Measured post storm profile
%               xbeach:         Profile computed by another version of
%                               XBeach
%               durosta:        Profile computed by DurosTA
%               duros:          Profile computed by DUROS
%               duros_p:        Profile computed by DUROS+
%               duros_pp:       Profile computed by D++
%               nonerodible:    Non-erodible layer
%               title:          Figure title
%               units:          Units used for x- and z-axis
%               BSS:            Boolean indicating whether BSS should be
%                               included
%               flip:           Boolean indicated whether figure should be
%                               flipped in case dune is located left
%
%   Output:
%   none
%
%   Example
%   xb_plot_profile(xb, 'initial', profile0, 'measured', profile1)
%
%   See also xb_view

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
% Created: 13 Apr 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'measured',         [], ...
    'xbeach',           [], ...
    'durosta',          [], ...
    'duros',            [], ...
    'duros_p',          [], ...
    'duros_pp',         [], ...
    'other',            [], ...
    'nonerodible',      [], ...
    'title',            '', ...
    'BSS',              true, ...
    'flip',             true, ...
    'units',            'm' ...
);

OPT = setproperty(OPT, varargin{:});

%% plot

fh = figure; hold on;

% read data
x = xb_get(xb, 'DIMS.globalx_DATA');
z = xb_get(xb, 'zb');
j = ceil(size(x,1)/2);

zb0 = [squeeze(x(j,:))' squeeze(z(1,j,:))];
zb1 = [squeeze(x(j,:))' squeeze(z(2:end,j,:))'];

% plot profiles
addplot(zb0,                '-',    2,  'k',        'initial'           );
addplot(OPT.measured,       '-',    1,  'k',        'measured'          );
addpatch(OPT.nonerodible,'none',[.5 .5 .5],0.7,     'non-erodible'      );

addplot(OPT.other,          '--',   1,  'c',        'other'             );
addplot(OPT.durosta,        '-',    1,  'b',        'DurosTA'           );
addplot(OPT.duros,          ':',    1,  'g',        'DUROS'             );
addplot(OPT.duros_p,        '-',    1,  'g',        'DUROS+'            );
addplot(OPT.duros_pp,       '-.',   1,  'g',        'D++'               );

addplot(OPT.xbeach,         '-' ,   1,  'r',        'XBeach'            );
addplot(zb1,                '-',    2,  'r',        'XBeach (current)'  );

% add BSS
if OPT.BSS && ~isempty(OPT.measured)
    xm = OPT.measured(:,1);
    zm = OPT.measured(:,2);
    
    c = get(gca, 'Children');
    for i = 1:length(c)
        name = get(c(i), 'DisplayName');
        if ~any(strcmpi(name, {'initial', 'measured', 'non-erodible'}))
            xc = get(c(i), 'XData')';
            zc = get(c(i), 'YData')';
            
            [r2 sci relbias bss] = xb_skill([xm zm], [xc zc], 'var', 'zb');
            
            set(c(i), 'DisplayName', sprintf('%s - BSS=%4.2f', name, bss));
        end
    end
end

% add labels
title('profiles');
xlabel(['distance [' OPT.units ']']);
ylabel(['height [' OPT.units ']']);

legend('show', 'Location', 'NorthWest')

% flip figure if necessary
if OPT.flip
    dz  = zb1(:,2) - zb0(:,2);
    if find(dz==max(dz)) > find(dz==min(dz))
        set(gca, 'XDir', 'reverse');
    end
end

set(gca, 'XLim', [min(x(j,:)) max(x(j,:))]);

box on;
grid on;

end
%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function addpatch(data, linetype, facecolor, facealpha, name)
if ~isempty(data)
    for i = 2:size(data,2)
        xdata = [data(:,1); data(end,1); data(1,1)];
        zdata = [data(:,i); min(data(:,i)); min(data(:,i))];
        p = patch(xdata, zdata,'k',...
            'LineStyle', linetype, ...
            'FaceColor', facecolor, ...
            'FaceAlpha',facealpha,...
            'DisplayName', name);
        
        hasbehavior(p,'legend',false);
    end
    
    hasbehavior(p,'legend',true);
end
end

function addplot(data, type, sz, color, name)
if ~isempty(data);
    for i = 2:size(data,2)
        p = plot(data(:,1), data(:,i), type, ...
            'Color', color, ...
            'LineWidth', sz, ...
            'DisplayName', name);
        
        hasbehavior(p,'legend',false);
    end
    
    hasbehavior(p,'legend',true);
end
end