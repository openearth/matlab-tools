function XB_Plot_Results(XB, vars, varargin)
%XB_PLOT_RESULTS  Plots selected variables from XBeach result structure
%
%   Plots selected variables from XBeach result structure in 2D or 3D
%   depending on the type of structure.
%
%   Syntax:
%   XB_Plot_Results(XB, vars, varargin)
%
%   Input:
%   XB          = XBeach result structure
%   vars        = cell with variables to be plotted
%   varargin    = key/value pairs of optional parameters
%                 fh            = figure handle (default: [])
%                 t             = time step to be observed (default: 1)
%                 title         = title of figure (default: XBeach output
%                                 plot)
%                 size          = size of figure (default: [800 600])
%                 view          = view angle of plot, if 3D (default: [37.5
%                                 30])
%                 xlim          = x limits of plot (default: [])
%                 ylim          = y limits of plot (default: [])
%                 zlim          = z limits of plot (default: [])
%                 showCoastline = flag to show coastline in plot (default:
%                                 false)
%
%   Output: no output
%
%   Example
%   XB_Plot_Results(XB, vars)
%
%   See also XB_Read_Results, XB_Animate_Results, XB_Read_Coastline

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Bas Hoonhout
%
%       bas@hoonhout.com
%
%       Stevinweg 1
%       2628CN Delft
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

% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 2 Dec 2009
% Created with Matlab version: 7.5.0.338 (R2007b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% settings

OPT = struct( ...
    'fh', [], ...
    't', 1, ...
    'title', 'XBeach output plot', ...
    'size', [800 600], ...
    'grid', true, ...
    'view', [37.5 30], ...
    'xlim', [], ...
    'ylim', [], ...
    'zlim', [], ...
    'showCoastline', false ...
);

OPT = setProperty(OPT, varargin{:});

% make sure variable is a cell structure
if ~iscell(vars); vars = {vars}; end;

%% initialization

% create figure
if isempty(OPT.fh)
    fig = figure();
else
    fig = OPT.fh;
end
    
% set figure size
pos = get(fig, 'Position'); pos(3:4) = OPT.size;
set(fig, 'Position', pos);
    
% read grid
xVar = XB.Output.x;
yVar = XB.Output.y;
dVar = XB.Output.zb;

wPlots = ceil(sqrt(length(vars)));
hPlots = ceil(length(vars)/wPlots);
    
%% plot data

% loop through variables to animate
for i = 1:length(vars)
    var = vars{i};
    
    % create subplot
    hp = subplot(wPlots, hPlots, i);

    % read output variable
    zVar = XB.Output.(var);
    zSize = size(zVar);

    % determine space and time dimensions
    switch length(zSize)
        case 2
            plot3D = false;
            plotAxis = [min(min(xVar)) max(max(xVar)) min(min(zVar)) max(max(zVar))];
        case 3
            plot3D = true;
            plotAxis = [min(min(xVar)) max(max(xVar)) min(min(yVar)) max(max(yVar)) min(min(min(zVar))) max(max(max(zVar)))];
        otherwise
            error('Provided variable has not the right amount of dimensions');
    end
    
    if OPT.xlim; plotAxis(1:2) = OPT.xlim; end;
    if OPT.ylim; plotAxis(3:4) = OPT.ylim; end;
    if OPT.zlim; plotAxis(5:6) = OPT.zlim; end;

    % plot frame
    if plot3D
        surface(xVar, yVar, zVar(:,:,OPT.t));
        axis(plotAxis);
        
        if OPT.showCoastline ~= false
            [x y] = XB_Read_Coastline(XB, OPT.showCoastline, 't', OPT.t);
            
            hold on
            
            plot(x, y, '-r', 'LineWidth', 3);
        end

        set(gca, 'View', OPT.view);
    else
        plot(xVar, zVar(:,OPT.t));
        axis(plotAxis);
    end
        
    % set grid
    if OPT.grid; grid on; else grid off; end;

    % update title
    title({[OPT.title] ['Variable: ' var ' ; Timestep: ' num2str(OPT.t)]});
end