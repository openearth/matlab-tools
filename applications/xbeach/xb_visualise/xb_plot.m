function xb_plot(xb, varargin)
%XB_PLOT  Basic visualisation tool for XBeach output structure
%
%   Creates a basic interface to visualise contents of a XBeach output
%   structure. The function is meant to be basic and provide first
%   visualisations of model results.
%
%   WARNING: THIS FUNCTION ONLY WORKS WITH A XBEACH STRUCTURE OBTAINED
%   USING THE XB_READ_DAT FUNCTION, SINCE XB_READ_NETCDF HAS A DIFFERENT
%   DIMENSION ORDER.
%
%   Syntax:
%   varargout = xb_plot(xb, varargin)
%
%   Input:
%   xb        = XBeach structure array
%   varargin  = none
%
%   Output:
%   none
%
%   Example
%   xb_plot(xb)
%
%   See also xb_read_dat

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
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
% Created: 07 Dec 2010
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
);

OPT = setproperty(OPT, varargin{:});

%% determine dimensions

t = xb_get(xb,'DIMS.tsglobal');
nt = xb_get(xb,'DIMS.nt');

% get variable list
vars = {xb.data.name};
idx = strcmpi(vars, {'DIMS'});
vars = vars(~idx);
varlist = sprintf('|%s', vars{:});
varlist = varlist(2:end);

%% create gui

winsize = [800 600];

fig = figure('Position', [100 100 winsize]);

axes('Position', [.1 .2 .7 .7], 'Tag', 'Axes');

% sliders
uicontrol(fig, 'Style', 'slider', 'Tag', 'Slider1', ...
    'Min', 1, 'Max', nt, 'Value', 1, ...
    'Position', [[.1 .125].*winsize [.7 .025].*winsize], ...
    'Enable', 'off', ...
    'Callback', {@ui_loaddata, xb});

uicontrol(fig, 'Style', 'slider', 'Tag', 'Slider2', ...
    'Min', 1, 'Max', nt, 'Value', nt, ...
    'Position', [[.1 .075].*winsize [.7 .025].*winsize], ...
    'Callback', {@ui_loaddata, xb});

uicontrol(fig, 'Style', 'text', 'Tag', 'TextSlider1', ...
    'String', num2str(t(1)), 'HorizontalAlignment', 'left', ...
    'Position', [[.1 .025].*winsize [.3 .025].*winsize]);

uicontrol(fig, 'Style', 'text', 'Tag', 'TextSlider2', ...
    'String', num2str(t(end)), 'HorizontalAlignment', 'right', ...
    'Position', [[.5 .025].*winsize [.3 .025].*winsize]);

% variable selector
uicontrol(fig, 'Style', 'listbox', 'Tag', 'SelectVar', ...
    'String', varlist, 'Min', 1, 'Max', length(vars), ...
    'Position', [[.85 .65].*winsize [.1 .25].*winsize], ...
    'Callback', {@ui_loaddata, xb});

% options
uicontrol(fig, 'Style', 'checkbox', 'Tag', 'ToggleDiff', ...
    'String', 'diff', ...
    'Position', [[.85 .6].*winsize [.1 .05].*winsize], ...
    'Callback', {@ui_togglediff, xb});

uicontrol(fig, 'Style', 'checkbox', 'Tag', 'ToggleSurf', ...
    'String', 'surf', ...
    'Position', [[.85 .55].*winsize [.1 .05].*winsize], ...
    'Enable', 'off', ...
    'Callback', {@ui_togglesurf, xb});

% animate button
uicontrol(fig, 'Style', 'togglebutton', 'Tag', 'ToggleAnimate', ...
    'String', 'Animate', ...
    'Position', [[.85 .07].*winsize [.1 .035].*winsize], ...
    'Callback', {@ui_animate, xb});

set(findobj(fig, 'Type', 'uicontrol'), 'BackgroundColor', [.8 .8 .8]);

% show data
ui_loaddata(findobj(fig, 'Tag', 'SelectVar'), [], xb);

%% uicontrol functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ui_togglediff(hObj, event, xb)

pObj = get(hObj, 'Parent');

% enable/disable secondary slider
if get(hObj, 'Value')
    set(findobj(pObj, 'Tag', 'Slider1'), 'Enable', 'on');
else
    set(findobj(pObj, 'Tag', 'Slider1'), 'Enable', 'off');
end

% reload data
ui_loaddata(hObj, event, xb)

function ui_togglesurf(hObj, event, xb)

pObj = get(hObj, 'Parent');

% clear current axes
cla(findobj(pObj, 'Type', 'Axes'));

% reload data
ui_loaddata(hObj, event, xb)

function ui_loaddata(hObj, event, xb)

pObj = get(hObj, 'Parent');

% get data
vars = get(findobj(pObj, 'Tag', 'SelectVar'), 'String');
vars = vars(get(findobj(pObj, 'Tag', 'SelectVar'), 'Value'),:);

colors = 'rgbcymk';

hold off;
for i = 1:size(vars,1)
    var = strtrim(vars(i,:));
    data = xb_get(xb, var);

    if ~isnan(data)

        idx = num2cell(ones(1, ndims(data))); idx(1:2) = {':' ':'};

        % get time
        t1 = round(get(findobj(pObj, 'Tag', 'Slider1'), 'Value'));
        t2 = round(get(findobj(pObj, 'Tag', 'Slider2'), 'Value'));

        % determine indices
        idx1 = [idx{1:end-1} {t1}];
        idx2 = [idx{1:end-1} {t2}];

        % get 2D array
        if get(findobj(pObj, 'Tag', 'ToggleDiff'), 'Value')
            data = data(idx2{:})-data(idx1{:});
        else
            data = data(idx2{:});
        end

        data = squeeze(data);

        % get grid
        x = xb_get(xb, 'DIMS.x');
        y = xb_get(xb, 'DIMS.y');

        % plot data
        if min(size(data)) <= 3
            set(findobj(pObj, 'Tag', 'ToggleSurf'), 'Enable', 'off')

            % 1D data
            sObj = findobj(findobj(pObj, 'Type', 'Axes'), 'Type', 'line');
            if length(sObj) >= i
                set(sObj(i), 'YData', data(:,1));
            else
                if ~isnan(x)
                    plot(x, data(:,1), ['-' colors(mod(i-1,length(colors))+1)]);
                else
                    plot(data(:,1), ['-' colors(mod(i-1,length(colors))+1)]);
                end
            end
        else
            set(findobj(pObj, 'Tag', 'ToggleSurf'), 'Enable', 'on')

            % 2D data
            if get(findobj(pObj, 'Tag', 'ToggleSurf'), 'Value')
                sObj = findobj(findobj(pObj, 'Type', 'Axes'), 'Type', 'surface');
                if length(sObj) >= i
                    set(sObj(i), 'ZData', data);
                else
                    if ~isnan(x) & ~isnan(y)
                        surf(x, y, data);
                    else
                        surf(data);
                    end
                end
            else
                sObj = findobj(findobj(pObj, 'Type', 'Axes'), 'Type', 'surface');
                if length(sObj) >= i
                    set(sObj(i), 'CData', data);
                else
                    if ~isnan(x) & ~isnan(y)
                        pcolor(x, y, data);
                    else
                        pcolor(data);
                    end
                end
            end

            shading flat;
        end
    end
    
    hold on;
end

% clear items without use
sObj = get(findobj(pObj, 'Type', 'Axes'), 'Children');
for i = size(vars,1)+1:length(sObj)
    delete(sObj(i));
end

function ui_animate(hObj, event, xb)

pObj = get(hObj, 'Parent');

% get minimum, maximum and current time
tmin = get(findobj(pObj, 'Tag', 'Slider2'), 'Min');
tmax = get(findobj(pObj, 'Tag', 'Slider2'), 'Max');
t = round(get(findobj(pObj, 'Tag', 'Slider2'), 'Value'));

% update time
t = min(tmax, t+(tmax-tmin)/100);
set(findobj(pObj, 'Tag', 'Slider2'), 'Value', t);

% reload data
ui_loaddata(hObj, event, xb)

if t < tmax
    pause(.1);

    % start new loop if maximum is not reached
    if get(findobj(pObj, 'Tag', 'ToggleAnimate'), 'Value')
        ui_animate(hObj, event, xb)
    end
else
    
    % stop animation if maximum is reached
    set(findobj(pObj, 'Tag', 'ToggleAnimate'), 'Value', 0);
end