function xb_view(data, varargin)
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

if ~exist('data', 'var')
    data = pwd;
end

%% make gui

winsize = [OPT.width OPT.height];

sz = get(0, 'screenSize');
winpos = (sz(3:4)-winsize)/2;

fig = figure('Position', [winpos winsize], ...
    'Tag', 'xb_view', ...
    'Toolbar','figure',...
    'InvertHardcopy', 'off', ...
    'UserData', struct('input', data), ...
    'ResizeFcn', @ui_resize);

if OPT.modal; set(fig, 'WindowStyle', 'modal'); end;

ui_build(fig);

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ui_build(obj)
    ui_read(obj);
    
    % get info
    pobj = get_pobj(obj);
    info = get(pobj, 'userdata');
    
    sliderstep = [1 5]/(length(info.t)-1);
    
    % plot area
    uipanel(pobj, 'Tag', 'PlotPanel', 'Title', 'plot', 'Unit', 'pixels');

    % sliders
    uicontrol(pobj, 'Style', 'slider', 'Tag', 'Slider1', ...
        'Min', 1, 'Max', length(info.t), 'Value', 1, 'SliderStep', sliderstep, ...
        'Enable', 'off', ...
        'Callback', @ui_plot);

    uicontrol(pobj, 'Style', 'slider', 'Tag', 'Slider2', ...
        'Min', 1, 'Max', length(info.t), 'Value', length(info.t), 'SliderStep', sliderstep, ...
        'Callback', @ui_plot);

    uicontrol(pobj, 'Style', 'text', 'Tag', 'TextSlider', ...
        'String', num2str(info.t(end)), 'HorizontalAlignment', 'center');
    
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
    
    uicontrol(pobj, 'Style', 'checkbox', 'Tag', 'ToggleCompare', ...
        'String', 'compare', ...
        'Enable', 'off', ...
        'Callback', @ui_togglediff);

    uicontrol(pobj, 'Style', 'checkbox', 'Tag', 'ToggleSurf', ...
        'String', 'surf', ...
        'Enable', 'off', ...
        'Callback', @ui_togglesurf);
    
    uicontrol(pobj, 'Style', 'checkbox', 'Tag', 'ToggleCAxisFix', ...
        'String', 'fix caxis', ...
        'Enable', 'off', ...
        'Callback', @ui_togglecaxis);

    % reload button
    uicontrol(pobj, 'Style', 'pushbutton', 'Tag', 'ButtonReload', ...
        'String', 'Reload', ...
        'Callback', @ui_reload);
    
    % animate button
    uicontrol(pobj, 'Style', 'togglebutton', 'Tag', 'ToggleAnimate', ...
        'String', 'Animate', ...
        'Callback', @ui_animate);

    set(findobj(pobj, 'Type', 'uicontrol'), 'BackgroundColor', [.8 .8 .8]);
    set(findobj(pobj, 'Type', 'uipanel'), 'BackgroundColor', [.8 .8 .8]);
    
    % set exceptions
    if info.ndims == 1
        set(findobj(pobj, 'Tag', 'ToggleCompare'), 'Enable', 'on');
    end
    
    if info.ndims == 2
        set(findobj(pobj, 'Tag', 'ToggleSurf'), 'Enable', 'on');
        set(findobj(pobj, 'Tag', 'ToggleCAxisFix'), 'Enable', 'on');
    end
    
    if strcmpi(info.type, 'input')
        set(findobj(pobj, 'Tag', 'ToggleDiff'), 'Enable', 'off');
        set(findobj(pobj, 'Tag', 'Slider2'), 'Enable', 'off');
        set(findobj(pobj, 'Tag', 'ToggleAnimate'), 'Enable', 'off');
    end
    
    % reading indicator
    uicontrol(pobj, 'Style', 'text', 'Tag', 'ReadIndicator', ...
        'String', 'READING', 'HorizontalAlignment', 'center', ...
        'BackgroundColor', 'red', 'FontWeight', 'bold', 'Visible', 'off');
    
    ui_resize(pobj, []);
    
    ui_plot(pobj, []);
end

function ui_reload(obj, event)
    ui_read(obj);
    
    % get info
    pobj = get_pobj(obj);
    info = get(pobj, 'userdata');
    
    sliderstep = [1 5]/(length(info.t)-1);
    
    % sliders
    set(findobj(pobj, 'Tag', 'Slider1'), 'Max', length(info.t), 'SliderStep', sliderstep)
    set(findobj(pobj, 'Tag', 'Slider2'), 'Max', length(info.t), 'SliderStep', sliderstep, 'Value', length(info.t))
    set(findobj(pobj, 'Tag', 'TextSlider1'), 'String', num2str(info.t(1)))
    set(findobj(pobj, 'Tag', 'TextSlider2'), 'String', num2str(info.t(end)))
    
    ui_plot(pobj, []);
end

function ui_resize(obj, event)

    pos = get(obj, 'Position');
    winsize = pos(3:4);

    set(findobj(obj, 'Tag', 'PlotPanel'), 'Position', [[.075 .2].*winsize [.75 .75].*winsize]);
    set(findobj(obj, 'Tag', 'Slider1'), 'Position', [[.1 .125].*winsize [.7 .025].*winsize]);
    set(findobj(obj, 'Tag', 'Slider2'), 'Position', [[.1 .075].*winsize [.7 .025].*winsize]);
    set(findobj(obj, 'Tag', 'TextSlider'), 'Position', [[.35 .025].*winsize [.2 .025].*winsize]);
    set(findobj(obj, 'Tag', 'TextSlider1'), 'Position', [[.1 .025].*winsize [.2 .025].*winsize]);
    set(findobj(obj, 'Tag', 'TextSlider2'), 'Position', [[.6 .025].*winsize [.2 .025].*winsize]);
    set(findobj(obj, 'Tag', 'SelectVar'), 'Position', [[.85 .65].*winsize [.1 .25].*winsize]);
    set(findobj(obj, 'Tag', 'ToggleDiff'), 'Position', [[.85 .6].*winsize [.1 .05].*winsize]);
    set(findobj(obj, 'Tag', 'ToggleCompare'), 'Position', [[.85 .55].*winsize [.1 .05].*winsize]);
    set(findobj(obj, 'Tag', 'ToggleSurf'), 'Position', [[.85 .5].*winsize [.1 .05].*winsize]);
    set(findobj(obj, 'Tag', 'ToggleCAxisFix'), 'Position', [[.85 .45].*winsize [.1 .05].*winsize]);
    set(findobj(obj, 'Tag', 'ButtonReload'), 'Position', [[.85 .125].*winsize [.1 .035].*winsize]);
    set(findobj(obj, 'Tag', 'ToggleAnimate'), 'Position', [[.85 .07].*winsize [.1 .035].*winsize]);
    set(findobj(obj, 'Tag', 'ReadIndicator'), 'Position', [[.85 .25].*winsize [.1 .025].*winsize]);
end

function ui_togglediff(obj, event)
    pobj = get_pobj(obj);

    % enable/disable secondary slider
    if get(obj, 'Value')
        set(findobj(pobj, 'Tag', 'Slider1'), 'Enable', 'on');
    else
        set(findobj(pobj, 'Tag', 'Slider1'), 'Enable', 'off');
    end
    
    info = get(pobj, 'userdata');
    info.(get(obj, 'String')) = get(obj, 'Value');
    set(pobj, 'userdata', info);

    ui_plot(obj, []);
end

function ui_togglesurf(obj, event)
    pobj = get_pobj(obj);
    
    info = get(pobj, 'userdata');
    info.surf = get(obj, 'Value');
    set(pobj, 'userdata', info);

    cla(get_axis(obj));

    ui_plot(obj, []);
end

function ui_togglecaxis(obj, event)
    pobj = get_pobj(obj);
    
    info = get(pobj, 'userdata');
    if get(obj, 'Value')
        info.caxis = get(get_axis(obj), 'CLim');
    else
        info.caxis = [];
    end
    set(pobj, 'userdata', info);
    
    ui_plot(obj, []);
end

function ui_read(obj)
    pobj = get_pobj(obj);
    info = get(pobj, 'userdata');

    if isfield(info, 'input')
        if xb_check(info.input)
            switch info.input.type
                case 'input'
                    info.type = 'input';
                    
                    % read variables
                    info.vars = {'depfile.depfile'};
                    
                    info.t = [0 1];
                    
                    [info.x info.y] = xb_input2bathy(info.input);
                case 'output'
                    info.type = 'output_xb';
                    
                    % read dimensions
                    info.dims = xb_get(info.input, 'DIMS');
                    info.dims = cell2struct({info.dims.data.value}, {info.dims.data.name}, 2);
                    
                    % read variables
                    info.vars = {info.input.data.name};
                    info.vars = info.vars(~strcmpi(info.vars, 'DIMS'));
                    
                    % determine grid and time
                    info.t = info.dims.globaltime_DATA;
                    info.x = info.dims.globalx_DATA;
                    info.y = info.dims.globaly_DATA;
                otherwise
                    error('Unsupported XBeach strucure supplied');
            end
        elseif ischar(info.input) && (exist(info.input, 'dir') || exist(info.input, 'file'))
        
            info.type = 'output_dir';
            info.fpath = info.input;

            % read dimensions
            info.dims = xb_read_dims(info.fpath);

            % read variables
            info.vars = xb_get_vars(info.fpath);

            % determine grid and time
            info.t = info.dims.globaltime_DATA;
            info.x = info.dims.globalx_DATA;
            info.y = info.dims.globaly_DATA;
        else
            error('No valid data supplied');
        end
        
        % generate var list
        info.varlist = sprintf('|%s', info.vars{:});
        info.varlist = info.varlist(2:end);
        
        % determine plot type
        if min(size(info.x)) <= 3
            info.ndims = 1;
        else
            info.ndims = 2;
        end
        
        info.diff = false;
        info.compare = false;
        info.surf = false;
        info.caxis = [];
        
        set(pobj, 'userdata', info);
    else
        error('No data supplied');
    end
end

function data = ui_getdata(obj, info, vars, slider)
    pobj = get_pobj(obj);
    
    iobj = findobj(pobj, 'Tag', 'ReadIndicator');
    set(iobj, 'Visible', 'on'); drawnow;
    
    data = cell(size(vars));
    
    t1 = round(get(findobj(pobj, 'Tag', 'Slider1'), 'Value'));
    t2 = round(get(findobj(pobj, 'Tag', 'Slider2'), 'Value'));
    
    if exist('slider', 'var') && slider == 1
        slider = 1;
        t = t1;
    else
        slider = 2;
        t = t2;
    end
    
    switch info.type
        case 'input'
            for i = 1:length(vars)
                data{i}(1,:,:) = xb_get(info.input, vars{:});
            end
        case 'output_xb'
            for i = 1:length(vars)
                d = xb_get(info.input, vars{i});
                data{i}(1,:,:) = d(t,:,:);
            end
        case 'output_dir'
            [data{1:length(vars)}] = xb_get( ...
                xb_read_output(info.fpath, 'vars', vars, 'start', [t-1 0 0], ...
                'length', [1 -1 -1]), vars{:});
    end
    
    if info.diff && slider == 2
        data0 = ui_getdata(obj, info, vars, 1);
        data = cellfun(@minus, data, data0, 'UniformOutput', false);
    end
    
    tobj = findobj(pobj, 'Tag', 'TextSlider');
    if info.diff
        set(tobj, 'String', [num2str(info.t(t2)) ' - ' num2str(info.t(t1))]);
    elseif info.compare
        set(tobj, 'String', [num2str(info.t(t1)) ' -> ' num2str(info.t(t2))]);
    else
        set(tobj, 'String', num2str(info.t(t2)));
    end
    
    set(iobj, 'Visible', 'off');
end

function ui_plot(obj, event)
    pobj = get_pobj(obj);
    info = get(pobj, 'userdata');
    
    if ismember(get(obj, 'Tag'), {'SelectVar' 'ToggleSurf' 'ToggleCompare'})
        delete(get_axis(obj));
    end
    
    vars = selected_vars(obj);
    data = ui_getdata(obj, info, vars, 2);
    
    switch info.ndims
        case 1
            if info.compare
                data0 = ui_getdata(obj, info, vars, 1);
                data = cat(1, data, data0);
            end
            
            plot_1d(obj, info, data, vars);
        case 2
            plot_2d(obj, info, data, vars);
    end
end

function ui_animate(obj, event)
    pobj = get_pobj(obj);

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
            pause(.1)
            ui_animate(obj, event)
        end
    else
        set(findobj(pobj, 'Tag', 'ToggleAnimate'), 'Value', 0);
    end
end

function plot_1d(obj, info, data, vars)
    pobj = get_pobj(obj);
    
    update = true;
    ax = get_axis(obj);
    if isempty(ax)
        update = false;
        ax = axes('Parent', findobj(pobj, 'Tag', 'PlotPanel')); hold on;
    end
    
    lines = flipud(findobj(ax, 'Type', 'line'));
    
    n = ceil(length(data)/length(vars))-1;
    
    type = '-:';
    color = 'rgbcymk';
    for j = 0:n
        for i = 1:length(vars)
            ii = i+j*length(vars);
            
            if update
                set(lines(ii), 'XData', info.x(:,1), 'YData', squeeze(data{ii}(:,1,:)));
            else
                plot(ax, info.x(1,:), squeeze(data{ii}(:,1,:)), ...
                    [type(1+j) color(mod(i-1,length(color))+1)], ...
                    'DisplayName', vars{i});
            end
        end
    end
    
    % include legend at the 'Best' location
    legend('show',...
        'Location', 'Best')
end

function plot_2d(obj, info, data, vars)
    pobj = get_pobj(obj);
    
    ax = get_axis(obj);
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
        
        data{i} = squeeze(data{i});
        
        if all(size(info.x) == size(data{i})) && all(size(info.y) == size(data{i}))
            if update
                set(surface(i), 'XData', info.x, 'YData', info.y, ...
                    'ZData', data{i}, 'CData', data{i});
            else
                if info.surf
                    surf(sp(i), info.x, info.y, data{i});
                else
                    pcolor(sp(i), info.x, info.y, data{i});
                end
            end
        
            shading flat; colorbar;
        end
        
        if iscell(info.caxis)
            info.caxis = info.caxis{min(i, length(info.caxis))};
        end
        
        if ~isempty(info.caxis)
            set(sp(i), 'CLim', info.caxis);
        else
            set(sp(i), 'CLimMode', 'auto');
        end
        
        title(vars{i}, 'Interpreter', 'none');
    end
    
    h = linkprop(sp, {'xlim' 'ylim' 'CameraPosition','CameraUpVector'});
    setappdata(sp(1), 'graphics_linkprop', h);
end

function vars = selected_vars(obj)
    pobj = get_pobj(obj);
    vars = get(findobj(pobj, 'Tag', 'SelectVar'), 'String');
    vars = vars(get(findobj(pobj, 'Tag', 'SelectVar'), 'Value'),:);
    vars = strtrim(num2cell(vars, 2));
end

function ax = get_axis(obj)
    pobj = get_pobj(obj);
    ax = findobj(pobj, 'Type', 'Axes', 'Tag', '');
end

function pobj = get_pobj(obj)
    if strcmpi(get(obj, 'Tag'), 'xb_view')
        pobj = obj;
    else
        pobj = get_pobj(get(obj, 'Parent'));
    end
end