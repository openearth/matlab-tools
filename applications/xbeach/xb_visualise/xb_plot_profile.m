function xb_plot_profile(varargin)
%XB_PLOT_PROFILE  Create uniform profile plots
%
%   Create uniform profile plots using standardized coloring per source.
%   Automatically computes Brier Skill Scores and makes sure the dune is
%   located right on the figure. Profiles are supplied in the form of
%   matrices from which the first column contains x-coordinates and
%   successive columns contain z-values.
%
%   Syntax:
%   xb_plot_profile(varargin)
%
%   Input:
%   varargin =  inital:         Initial profile
%               measured:       Measured post storm profile
%               testbed:        Profile computed by testbed
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
%   xb_plot_profile('initial', profile0, 'measured', profile1, 'testbed', xb)
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
    'initial',          [], ...
    'measured',         [], ...
    'testbed',          [], ...
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

figure; hold on;

% plot profiles
addplot(OPT.initial,        '--',   'k',        'initial'           );
addplot(OPT.measured,       '-',    'k',        'measured'          );
addplot(OPT.nonerodible,    '-',    [.5 .5 .5], 'non-erodible'      );

addplot(OPT.other,          '--',   'c',        'other'             );
addplot(OPT.durosta,        '-',    'b',        'DurosTA'           );
addplot(OPT.duros,          ':',    'g',        'DUROS'             );
addplot(OPT.duros_p,        '--',   'g',        'DUROS+'            );
addplot(OPT.duros_pp,       '-',    'g',        'D++'               );

addplot(OPT.xbeach,         '--',   'r',        'XBeach'            );
addplot(OPT.testbed,        '-',    'r',        'XBeach (testbed)'  );

% add BSS
if OPT.BSS && ~isempty(OPT.initial) && ~isempty(OPT.measured)
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
title(OPT.title, 'Interpreter', 'none');

xlabel(['distance [' OPT.units ']']);
ylabel(['height [' OPT.units ']']);

legend('show', 'Location', 'NorthWest')

% flip figure if necessary
if ~isempty(OPT.initial) && ~isempty(OPT.measured)
    x   = unique([OPT.initial(:,1) ; OPT.measured(:,1)]);
    
    if OPT.flip
        zi  = interp1(OPT.initial(:,1), OPT.initial(:,2), x);
        zm  = interp1(OPT.measured(:,1), OPT.measured(:,2), x);
        dz  = zm - zi;

        if find(dz==max(dz)) > find(dz==min(dz))
            set(gca, 'XDir', 'reverse');
        end
    end
    
    set(gca, 'XLim', [min(x) max(x)]);
end

box on;
grid on;

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function addplot(data, linetype, color, name)
    if ~isempty(data);
        for i = 2:size(data,2)
            p = plot(data(:,1), data(:,i), ...
                'Color', color, ...
                'LineStyle', linetype, ...
                'LineWidth', 2, ...
                'DisplayName', name);
            
            hasbehavior(p,'legend',false);
        end
        
        hasbehavior(p,'legend',true);
    end
end

end
