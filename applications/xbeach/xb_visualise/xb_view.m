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

if ~iscell(data)
    data = {data};
end

%% make gui

winsize = [OPT.width OPT.height];

sz = get(0, 'screenSize');
winpos = (sz(3:4)-winsize)/2;

fig = figure('Position', [winpos winsize], ...
    'Tag', 'xb_view', ...
    'Toolbar','figure',...
    'InvertHardcopy', 'off', ...
    'UserData', struct('input', {data}), ...
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
    
    if length(info.t)<=1
        close(obj);
        error('No data');
    end
    
    sliderstep = [1 5]/(length(info.t)-1);
    if length(info.t) == 1
        sliderstep = [1 1];
    end
    
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
        'Callback', @ui_togglediff);

    uicontrol(pobj, 'Style', 'checkbox', 'Tag', 'ToggleSurf', ...
        'String', 'surf', ...
        'Enable', 'off', ...
        'Callback', @ui_togglesurf);
    
    uicontrol(pobj, 'Style', 'checkbox', 'Tag', 'ToggleCAxisFix', ...
        'String', 'fix caxis', ...
        'Enable', 'off', ...
        'Callback', @ui_togglecaxis);
    
    uicontrol(pobj, 'Style', 'checkbox', 'Tag', 'ToggleTransect', ...
        'String', 'transect', ...
        'Enable', 'off', ...
        'Callback', @ui_toggletransect);
    
    uicontrol(pobj, 'Style', 'slider', 'Tag', 'SliderTransect', ...
        'Min', 1, 'Max', size(info.y,1), 'Value', 1, 'SliderStep', min(1,max(0,[1 5]/(size(info.y,1)-1))), ...
        'Enable', 'off', ...
        'Callback', @ui_settransect);

    % buttons
    uicontrol(pobj, 'Style', 'pushbutton', 'Tag', 'ButtonAlign', ...
        'String', 'Align', ...
        'Enable', 'off', ...
        'Callback', @ui_align);
    
    uicontrol(pobj, 'Style', 'pushbutton', 'Tag', 'ButtonReload', ...
        'String', 'Reload', ...
        'Callback', @ui_reload);
    
    uicontrol(pobj, 'Style', 'togglebutton', 'Tag', 'ToggleAnimate', ...
        'String', 'Animate', ...
        'Callback', @ui_animate);

    set(findobj(pobj, 'Type', 'uicontrol'), 'BackgroundColor', [.8 .8 .8]);
    set(findobj(pobj, 'Type', 'uipanel'), 'BackgroundColor', [.8 .8 .8]);
    
    % set exceptions
    if info.ndims == 2
        set_enable(obj, '2d');
    else
        set_enable(obj, '1d');
    end
    
    if strcmpi(info.type, 'input')
        set_enable(obj, 'input');
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
    set(findobj(obj, 'Tag', 'ToggleTransect'), 'Position', [[.85 .40].*winsize [.1 .05].*winsize]);
    set(findobj(obj, 'Tag', 'SliderTransect'), 'Position', [[.85 .375].*winsize [.1 .025].*winsize]);
    set(findobj(obj, 'Tag', 'ButtonAlign'), 'Position', [[.85 .18].*winsize [.1 .035].*winsize]);
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
    if get(obj, 'Value')
        set(findobj(pobj, 'Tag', 'ToggleTransect'), 'Enable', 'off');
        info.surf = true;
    else
        set(findobj(pobj, 'Tag', 'ToggleTransect'), 'Enable', 'on');
        info.surf = false;
    end
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

function ui_toggletransect(obj, event)
    pobj = get_pobj(obj);
    
    info = get(pobj, 'userdata');
    if get(obj, 'Value')
        set_enable(obj, '1d');
        set(findobj(pobj, 'Tag', 'ToggleTransect'), 'Enable', 'on');
        sobj = findobj(pobj, 'Tag', 'SliderTransect');
        set(sobj, 'Enable', 'on');
        
        ax = get_axis(obj);
        set(gcf,'CurrentAxes',ax(1)); [x y] = ginput(1);
        [y i] = closest(y, info.y(:,1));
        set(sobj, 'Value', i);
        
        info.transect = [y i];
    else
        set_enable(obj, '2d');
        
        set(findobj(pobj, 'Tag', 'SliderTransect'), 'Enable', 'off');
        
        info.transect = [];
    end
    set(pobj, 'userdata', info);
    
    cla(get_axis(obj));
    
    ui_plot(obj, []);
end

function ui_settransect(obj, event)
    pobj = get_pobj(obj);
    sobj = findobj(pobj, 'Tag', 'SliderTransect');
    
    info = get(pobj, 'userdata');
    i = round(get(sobj, 'Value'));
    info.transect = [info.y(i,1) i];
    set(pobj, 'userdata', info);
    
    ui_plot(obj, []);
end

function ui_align(obj, event)
    ax = get_axis(obj);
    
    clim = get(ax, 'CLim');
    
    if iscell(clim)
        clim = cell2mat(clim);
        clim = [min(clim(:,1)) max(clim(:,2))];
    end
    
    set(ax, 'CLim', clim);
end

function ui_read(obj)
    pobj = get_pobj(obj);
    info = get(pobj, 'userdata');

    if isfield(info, 'input')
        
        for i = 1:length(info.input)
            
            info0 = info;
        
            if xb_check(info.input{i})
                switch info.input{i}.type
                    case 'input'
                        info.type = 'input';

                        % read variables
                        info.vars = {'depfile.depfile'};

                        info.t = [0 1];

                        [info.x info.y] = xb_input2bathy(info.input{i});
                        
                        if isempty(info.x) || isempty(info.y)
                            [nx ny dx dy] = xb_get(info.input{i}, 'nx', 'ny', 'dx', 'dy');
                            
                            dx = max([1 dx]);
                            dy = max([1 dy]);
                            
                            [info.x info.y] = meshgrid(1:dx:dx*(nx+1), 1:dy:dy*(ny+1));
                        end
                    case 'output'
                        info.type = 'output_xb';

                        % read dimensions
                        info.dims = xb_get(info.input{i}, 'DIMS');
                        info.dims = cell2struct({info.dims.data.value}, {info.dims.data.name}, 2);

                        % read variables
                        info.vars = {info.input{i}.data.name};
                        info.vars = info.vars(~strcmpi(info.vars, 'DIMS'));

                        % determine grid and time
                        info.t = info.dims.globaltime_DATA;
                        info.x = info.dims.globalx_DATA;
                        info.y = info.dims.globaly_DATA;
                    case 'run'

                        info.type = 'output_dir';
                        info.fpath{i} = xb_get(info.input{i}, 'path');

                        % read dimensions
                        info.dims = xb_read_dims(info.fpath{i});

                        % read variables
                        info.vars = xb_get_vars(info.fpath{i});

                        % determine grid and time
                        info.t = info.dims.globaltime_DATA;
                        info.x = info.dims.globalx_DATA;
                        info.y = info.dims.globaly_DATA;
                    otherwise
                        error('Unsupported XBeach strucure supplied');
                end
            elseif ischar(info.input{i}) && (exist(info.input{i}, 'dir') || exist(info.input{i}, 'file'))

                info.type = 'output_dir';
                info.fpath{i} = info.input{i};

                % read dimensions
                info.dims = xb_read_dims(info.fpath{i});

                % read variables
                info.vars = xb_get_vars(info.fpath{i});

                % determine grid and time
                info.t = info.dims.globaltime_DATA;
                info.x = info.dims.globalx_DATA;
                info.y = info.dims.globaly_DATA;
            else
                error('No valid data supplied');
            end
            
            % check consistency
            if isfield(info0, 't')
                info.t = info.t(info.t<=max(info0.t));
                if length(info.t) ~= length(info0.t);           error('Inconsistent time axes length');     end;
                if ~all(info.t - info0.t == 0);                 error('Inconsistent time axes stepsize');   end;
            end
            
            if isfield(info0, 'x')
                if ~all(size(info.x) - size(info0.x) == 0);     error('Inconsistent x axes length');        end;
                if ~all(all(info.x - info0.x == 0));            error('Inconsistent x coordinates');        end;
            end
            
            if isfield(info0, 'y')
                if ~all(size(info.y) - size(info0.y) == 0);     error('Inconsistent y axes length');        end;
                if ~all(all(info.y - info0.y == 0));            error('Inconsistent y coordinates');        end;
            end
            
            if isfield(info0, 'varlist')
                info.varlist = intersect(info.vars, info0.vars);
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
            info.transect = [];
        end
        
        set(pobj, 'userdata', info);
    else
        error('No data supplied');
    end
end

function data = ui_getdata(obj, info, vars, slider)
    pobj = get_pobj(obj);
    
    iobj = findobj(pobj, 'Tag', 'ReadIndicator');
    set(iobj, 'Visible', 'on'); drawnow;
    
    m = length(info.input);
    n = length(vars);
    
    data{1} = nan([1 size(info.x,1) size(info.x,2)]);
    for i = 2:m*n
        data{i} = data{1};
    end
    
    t1 = round(get(findobj(pobj, 'Tag', 'Slider1'), 'Value'));
    t2 = round(get(findobj(pobj, 'Tag', 'Slider2'), 'Value'));
    
    if exist('slider', 'var') && slider == 1
        slider = 1;
        t = t1;
    else
        slider = 2;
        t = t2;
    end
    
    if ~isempty(info.transect)
        ri = info.transect(2);
        rl = 1;
    else
        ri = 1;
        rl = size(info.x,1);
    end
    
    for j = 1:m
        switch info.type
            case 'input'
                for i = 1:n
                    data{i}(1,:,:) = xb_get(info.input{j}, vars{:});
                    data{(j-1)*n+i} = data{i}(1,ri+[0:rl-1],:);
                end
            case 'output_xb'
                for i = 1:n
                    d = xb_get(info.input{j}, vars{i});
                    data{(j-1)*n+i}(1,:,:) = d(t,ri+[0:rl-1],:);
                end
            case 'output_dir'
                [data{(j-1)*n+[1:n]}] = xb_get( ...
                    xb_read_output(info.fpath{j}, 'vars', vars, 'start', [t-1 ri-1 0], ...
                    'length', [1 rl -1]), vars{:});
        end
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
    
    if ismember(get(obj, 'Tag'), {'SelectVar' 'ToggleSurf' 'ToggleCompare' 'ToggleTransect'})
        delete(get_axis(obj));
    end
    
    vars = selected_vars(obj);
    data = ui_getdata(obj, info, vars, 2);
    
    if info.compare
        data0 = ui_getdata(obj, info, vars, 1);
        data = cat(2, data0, data);
    end
    
    if info.ndims == 1 || ~isempty(info.transect)
        plot_1d(obj, info, data, vars);
    else
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
    
    n  = numel(data);
    n2 = length(info.input);
    n3 = length(vars);
    n1 = ceil(n/n3/n2);
    
    type = '-:';
    color = 'rgbcymk';
    for i1 = 1:n1
        for i2 = 1:n2
            for i3 = 1:n3
                ii = i3+(i2-1)*n3+(i1-1)*n2*n3;

                if update
                    set(lines(ii),...
                        'XData', info.x(1,:),...
                        'YData', squeeze(data{ii}(:,1,:)));
                else
                    plot(ax,...
                        info.x(1,:), squeeze(data{ii}(:,1,:)), ...
                        [type(n1-i1+1) color(mod(i3-1,length(color))+1)], 'LineWidth', i2, ...
                        'DisplayName', strrep(get_name(obj, info, n, ii), '_', '\_'));
                end
            end
        end
    end
    
    if ~isempty(info.transect)
        title(sprintf('y = %3.2f m (i = %d)', info.transect(1), info.transect(2)), 'Interpreter', 'none');
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
    
    n  = numel(data);
    n2 = length(info.input);
    n3 = length(vars);
    n1 = ceil(n/n3/n2);
    
    sx = ceil(sqrt(n));
    sy = ceil(n/sx);
    
    sp = nan(1,n);
    for i1 = 1:n1
        for i2 = 1:n2
            for i3 = 1:n3
                ii = i3+(i2-1)*n3+(i1-1)*n2*n3;

                sp(ii) = subplot(sy, sx, ii, 'Parent', findobj(pobj, 'Tag', 'PlotPanel'));

                data{ii} = squeeze(data{ii});

                if all(size(info.x) == size(data{ii})) && all(size(info.y) == size(data{ii}))
                    if update
                        set(surface(ii), 'XData', info.x, 'YData', info.y, ...
                            'ZData', data{ii}, 'CData', data{ii});
                    else
                        if info.surf
                            surf(sp(ii), info.x, info.y, data{ii});
                        else
                            pcolor(sp(ii), info.x, info.y, data{ii});
                        end
                    end

                    shading flat; colorbar;
                end

                if iscell(info.caxis)
                    info.caxis = info.caxis{min(ii, length(info.caxis))};
                end

                if ~isempty(info.caxis)
                    set(sp(ii), 'CLim', info.caxis);
                else
                    set(sp(ii), 'CLimMode', 'auto');
                end
                
                title(get_name(obj, info, n, ii), 'Interpreter', 'none');
            end
        end
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

function name = get_name(obj, info, n, i)
    pobj = get_pobj(obj);
    
    vars = selected_vars(obj);
    
    n2 = length(info.input);
    n3 = length(vars);
    n1 = ceil(n/n3/n2);
    
    i1 = floor((i-1)/n3/n2)+1;
    i2 = floor((i-(i1-1)*n2*n3-1)/n3)+1;
    i3 = floor( i-(i2-1)*n3-(i1-1)*n2*n3-1)+1;
    
    if n1 > 1 && i1 == 1
        t = round(get(findobj(pobj, 'Tag', 'Slider1'), 'Value'));
    else
        t = round(get(findobj(pobj, 'Tag', 'Slider2'), 'Value'));
    end
    
    name = sprintf('%s (file #%d, t = %d)', vars{i3}, i2, info.t(t));
end

function set_enable(obj, opt)
    pobj = get_pobj(obj);

    if ~iscell(opt)
        opt = {opt};
    end
    
    if ismember('1d', opt)
        set(findobj(pobj, 'Tag', 'ToggleSurf'), 'Enable', 'off');
        set(findobj(pobj, 'Tag', 'ToggleCAxisFix'), 'Enable', 'off');
        set(findobj(pobj, 'Tag', 'ToggleTransect'), 'Enable', 'off');
        set(findobj(pobj, 'Tag', 'ButtonAlign'), 'Enable', 'off');
    end
    
    if ismember('2d', opt)
        set(findobj(pobj, 'Tag', 'ToggleSurf'), 'Enable', 'on');
        set(findobj(pobj, 'Tag', 'ToggleCAxisFix'), 'Enable', 'on');
        set(findobj(pobj, 'Tag', 'ToggleTransect'), 'Enable', 'on');
        set(findobj(pobj, 'Tag', 'ButtonAlign'), 'Enable', 'on');
    end
    
    if ismember('input', opt)
        set(findobj(pobj, 'Tag', 'ToggleDiff'), 'Enable', 'off');
        set(findobj(pobj, 'Tag', 'Slider2'), 'Enable', 'off');
        set(findobj(pobj, 'Tag', 'ToggleAnimate'), 'Enable', 'off');
    end
end