function xb_view(fpath, varargin)
%XB_VIEW  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_view(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_view
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
% Created: 18 Jan 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'width',800,...
    'height',600, ...
    'modal', false ...
);

OPT = setproperty(OPT, varargin{:});

%% make gui

if isempty(findobj('tag', 'xb_view'))
    winsize = [OPT.width OPT.height];
    
    sz = get(0, 'screenSize');
    winpos = (sz(3:4)-winsize)/2;
    
    fig = figure('Position', [winpos winsize], ...
        'Tag', 'xb_view', ...
        'Toolbar','figure',...
        'InvertHardcopy', 'off', ...
        'UserData', struct('fpath', fpath), ...
        'ResizeFcn', @ui_resize);
    
    if OPT.modal; set(fig, 'WindowStyle', 'modal'); end;

    ui_build();
else
    error('XBeach Viewer instance already opened');
end

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ui_build()
    ui_read();
    
    % get info
    pobj = findobj('Tag', 'xb_view');
    info = get(pobj, 'userdata');
    
    % plot area
    uipanel(pobj, 'Tag', 'PlotPanel', 'Title', 'plot', 'Unit', 'pixels');

    % sliders
    uicontrol(pobj, 'Style', 'slider', 'Tag', 'Slider1', ...
        'Min', 1, 'Max', length(info.t), 'Value', 1, 'SliderStep', [.01 .1], ...
        'Enable', 'off', ...
        'Callback', @ui_plot);

    uicontrol(pobj, 'Style', 'slider', 'Tag', 'Slider2', ...
        'Min', 1, 'Max', length(info.t), 'Value', length(info.t), 'SliderStep', [.01 .1], ...
        'Callback', @ui_plot);

    uicontrol(pobj, 'Style', 'text', 'Tag', 'TextSlider1', ...
        'String', num2str(info.t(1)), 'HorizontalAlignment', 'left');

    uicontrol(pobj, 'Style', 'text', 'Tag', 'TextSlider2', ...
        'String', num2str(info.t(end)), 'HorizontalAlignment', 'right');

    % variable selector
    uicontrol(pobj, 'Style', 'listbox', 'Tag', 'SelectVar', ...
        'String', info.varlist, 'Min', 1, 'Max', length(info.vars), ...
        'Callback', @ui_plot);

    % options
    uicontrol(pobj, 'Style', 'checkbox', 'Tag', 'ToggleDiff', ...
        'String', 'diff', ...
        'Callback', @ui_togglediff);

    uicontrol(pobj, 'Style', 'checkbox', 'Tag', 'ToggleSurf', ...
        'String', 'surf', ...
        'Enable', 'off', ...
        'Callback', @ui_togglesurf);

    % animate button
    uicontrol(pobj, 'Style', 'togglebutton', 'Tag', 'ToggleAnimate', ...
        'String', 'Animate', ...
        'Callback', @ui_animate);

    set(findobj(pobj, 'Type', 'uicontrol'), 'BackgroundColor', [.8 .8 .8]);
    set(findobj(pobj, 'Type', 'uipanel'), 'BackgroundColor', [.8 .8 .8]);
    
    if strcmpi(info.type, '2D')
        set(findobj(pobj, 'Tag', 'ToggleSurf'), 'Enable', 'on');
    end
    
    ui_resize(pobj, []);
    
    ui_plot(pobj, []);
end

function ui_resize(obj, event)

    pos = get(obj, 'Position');
    winsize = pos(3:4);

    set(findobj(obj, 'Tag', 'PlotPanel'), 'Position', [[.075 .2].*winsize [.75 .75].*winsize]);
    set(findobj(obj, 'Tag', 'Slider1'), 'Position', [[.1 .125].*winsize [.7 .025].*winsize]);
    set(findobj(obj, 'Tag', 'Slider2'), 'Position', [[.1 .075].*winsize [.7 .025].*winsize]);
    set(findobj(obj, 'Tag', 'TextSlider1'), 'Position', [[.1 .025].*winsize [.3 .025].*winsize]);
    set(findobj(obj, 'Tag', 'TextSlider2'), 'Position', [[.5 .025].*winsize [.3 .025].*winsize]);
    set(findobj(obj, 'Tag', 'SelectVar'), 'Position', [[.85 .65].*winsize [.1 .25].*winsize]);
    set(findobj(obj, 'Tag', 'ToggleDiff'), 'Position', [[.85 .6].*winsize [.1 .05].*winsize]);
    set(findobj(obj, 'Tag', 'ToggleSurf'), 'Position', [[.85 .55].*winsize [.1 .05].*winsize]);
    set(findobj(obj, 'Tag', 'ToggleAnimate'), 'Position', [[.85 .07].*winsize [.1 .035].*winsize]);
end

function ui_togglediff(obj, event)
    pobj = findobj('Tag', 'xb_view');

    % enable/disable secondary slider
    if get(obj, 'Value')
        set(findobj(pobj, 'Tag', 'Slider1'), 'Enable', 'on');
    else
        set(findobj(pobj, 'Tag', 'Slider1'), 'Enable', 'off');
    end
    
    info = get(pobj, 'userdata');
    info.diff = get(obj, 'Value');
    set(pobj, 'userdata', info);

    ui_plot(obj, []);
end

function ui_togglesurf(obj, event)
    pobj = findobj('Tag', 'xb_view');
    
    info = get(pobj, 'userdata');
    info.surf = get(obj, 'Value');
    set(pobj, 'userdata', info);

    cla(findobj(pobj, 'Type', 'Axes'));

    ui_plot(obj, []);
end

function ui_read()
    pobj = findobj('Tag', 'xb_view');
    info = get(pobj, 'userdata');

    if isfield(info, 'fpath') && exist(info.fpath, 'dir')
        
        % read dimensions
        info.dims = xb_read_dims(info.fpath);
        
        % read variables
        info.vars = xb_get_vars(info.fpath);
        info.varlist = sprintf('|%s', info.vars{:});
        info.varlist = info.varlist(2:end);

        % determine grid and time
        info.t = info.dims.globaltime_DATA;

        [info.x info.y] = meshgrid(info.dims.globalx_DATA, info.dims.globaly_DATA);

        % determine plot type
        if info.dims.globaly <= 3
            info.type = '1D';
        else
            info.type = '2D';
        end
        
        info.diff = false;
        info.surf = false;

        set(pobj, 'userdata', info);
    else
        error(['Path not found [' info.fpath ']']);
    end
end

function ui_plot(obj, event)
    pobj = findobj('Tag', 'xb_view');
    info = get(pobj, 'userdata');
    
    if ismember(get(obj, 'Tag'), {'SelectVar' 'ToggleSurf'})
        delete(findobj(pobj, 'Type', 'Axes', '-not', 'Tag', 'legend'));
    end
    
    vars = selected_vars;
    
    t1 = round(get(findobj(pobj, 'Tag', 'Slider1'), 'Value'))-1;
    t2 = round(get(findobj(pobj, 'Tag', 'Slider2'), 'Value'))-1;
    
    data = {};
    [data{1:length(vars)}] = xb_get( ...
        xb_read_output(info.fpath, 'vars', vars, 'start', [t2 0 0], 'length', [1 -1 -1]), ...
        vars{:});
    
    if info.diff
        data0 = {};
        [data0{1:length(vars)}] = xb_get( ...
            xb_read_output(info.fpath, 'vars', vars, 'start', [t1 0 0], 'length', [1 -1 -1]), ...
            vars{:});
        
        data = cellfun(@minus, data, data0, 'UniformOutput', false);
    end
    
    switch info.type
        case '1D'
            plot_1d(info, data, vars);
        case '2D'
            plot_2d(info, data, vars);
    end
end

function ui_animate(obj, event)
    pobj = findobj('Tag', 'xb_view');

    % get minimum, maximum and current time
    tmin = get(findobj(pobj, 'Tag', 'Slider2'), 'Min');
    tmax = get(findobj(pobj, 'Tag', 'Slider2'), 'Max');
    t = round(get(findobj(pobj, 'Tag', 'Slider2'), 'Value'));

    % update time
    t = min(tmax, ceil(t+(tmax-tmin)/20));
    set(findobj(pobj, 'Tag', 'Slider2'), 'Value', t);

    % reload data
    ui_plot(obj, event); drawnow;

    % start new loop if maximum is not reached
    if t < tmax
        if get(findobj(pobj, 'Tag', 'ToggleAnimate'), 'Value')
            ui_animate(obj, event)
        end
    else
        set(findobj(pobj, 'Tag', 'ToggleAnimate'), 'Value', 0);
    end
end

function plot_1d(info, data, vars)
    pobj = findobj('Tag', 'xb_view');
    
    update = true;
    ax = findobj(pobj, 'Type', 'Axes', '-not', 'Tag', 'legend');
    if isempty(ax)
        update = false;
        ax = axes('Parent', findobj(pobj, 'Tag', 'PlotPanel')); hold on;
    end
    
    lines = findobj(ax, 'Type', 'line');
    
    color = 'rgbcymk';
    for i = 1:length(vars)
        if update
            set(lines(i), 'XData', info.x(1,:), 'YData', squeeze(data{i}(:,1,:)));
        else
            plot(ax, info.x(1,:), squeeze(data{i}(:,1,:)), ...
                ['-' color(mod(i-1,length(color))+1)], ...
                'DisplayName', vars{i});
        end
    end
end

function plot_2d(info, data, vars)
    pobj = findobj('Tag', 'xb_view');
    
    ax = findobj(pobj, 'Type', 'Axes', '-not', 'Tag', 'legend');
    if isempty(ax)
        update = false;
    else
        update = true;
    end
    
    surface = flipud(findobj(ax, 'Type', 'surface'));
    
    sx = ceil(sqrt(length(vars)));
    sy = ceil(length(vars)/sx);
    
    sp = nan(size(vars));
    for i = 1:length(vars)
        sp(i) = subplot(sy, sx, i, 'Parent', findobj(pobj, 'Tag', 'PlotPanel'));
        
        if update
            d = squeeze(data{i});
            set(surface(i), 'XData', info.x, 'YData', info.y, ...
                'ZData', d, 'CData', d);
        else
            if info.surf
                surf(sp(i), info.x, info.y, squeeze(data{i}));
            else
                pcolor(sp(i), info.x, info.y, squeeze(data{i}));
            end
        end
        
        shading flat;
        
        title(vars{i});
    end
    
    h = linkprop(sp, {'xlim' 'ylim' 'CameraPosition','CameraUpVector'});
    setappdata(sp(1), 'graphics_linkprop', h);
end

function vars = selected_vars()
    pobj = findobj('Tag', 'xb_view');
    vars = get(findobj(pobj, 'Tag', 'SelectVar'), 'String');
    vars = vars(get(findobj(pobj, 'Tag', 'SelectVar'), 'Value'),:);
    vars = strtrim(num2cell(vars, 2));
end