function donar_dia_view(D, varargin)
%DONAR_DIA_VIEW  Viewer for DIA struct
%
%   Simple viewer for DIA structs resulting from the donar_dia_read
%   function.
%
%   Syntax:
%   donar_dia_view(D, varargin)
%
%   Input:
%   D         = Result structure from donar_dia_read function
%   varargin  = none
%
%   Output:
%   none
%
%   Example
%   donar_dia_view(D)
%
%   See also donar_dia_read, donar_dia_parse

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 20 Apr 2012
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% build gui

figure( ...
    'Toolbar','figure',...
    'Tag','donar_dia_view', ...
    'UserData',struct('input',D), ...
    'InvertHardcopy', 'off', ...
    'ResizeFcn', @ui_resize);

ui_build(gcf);

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ui_build(obj)
    ui_read(obj);
    
    pobj = get_pobj(obj);
    info = get_info(obj);
    
    uicontrol(pobj, 'Style', 'listbox', 'Tag', 'SelectBlock', ...
        'String', info.blocklist, 'Min', 1, 'Max', 1, ...
        'Callback', @ui_set_block);
    
    uicontrol(pobj, 'Style', 'listbox', 'Tag', 'SelectData', ...
        'String', '', 'Min', 1, 'Max', 1, ...
        'Callback', @ui_set_data);
    
    uitable(pobj, 'Tag', 'TableMeta');
    
    ticktext(axes, '-datetime2');
    
    ui_resize(pobj, []);
    
    ui_set_block(obj);
    
end

function ui_resize(obj, event)

    pos = get(obj, 'Position');
    winsize = pos(3:4);

    set(get_obj(obj, 'SelectBlock'),'Position', [[.00 .25].*winsize [.25 .75].*winsize]);
    set(get_obj(obj, 'SelectData'), 'Position', [[.00 .00].*winsize [.25 .25].*winsize]);
    set(get_obj(obj, 'TableMeta'),  'Position', [[.25 .00].*winsize [.75 .25].*winsize]);

    set(get_axis(obj),'Units','pixels','Position', [[.35 .35].*winsize [.55 .55].*winsize]); box on;
    
end

function ui_set_block(obj, event)
    
    info           = get_info(obj);
    info.block     = get_selected(obj,'SelectBlock');
    info.blockn    = find(strcmpi(info.block{1},info.blocklistc));
    
    block = info.input.data(info.blockn).value;

    if xs_exist(block,'WRD')
        WRD            = xs_get(block,'WRD');
        dat            = {WRD.data.name};
        info.datalist  = sprintf('|%s', dat{:});
        info.datalist  = info.datalist(2:end);

        set(get_obj(obj,'SelectData'),'String',info.datalist);
    end

    set_info(obj,info);

    if xs_exist(block,'W3H')
        W3H            = xs_get(block,'W3H');
        f              = {W3H.data.name};
        v              = {W3H.data.value};
        idx            = ~cellfun(@iscell,v);
        v(idx)         = cellfun(@(x){x},v(idx),'UniformOutput',false);
        l              = cellfun(@(x)length(x),v);
        n              = max(l);

        dat            = cell(length(f),n);

        for i = 1:length(f)
            dat(i,1:l(i)) = v{i};
        end

        set(get_obj(obj,'TableMeta'),'Data',dat,'RowName',f,'ColumnWidth',{150});
    end
    
    ui_set_data(obj);
end

function ui_set_data(obj, event)
    
    info           = get_info(obj);
    info.data      = get_selected(obj,'SelectData');

    if iscell(info.data)
        info.data  = info.data{1};
    end
    
    set_info(obj,info);
    
    ui_plot(obj);
end

function ui_read(obj)

    info = get_info(obj);

    if isfield(info, 'input')
        D = info.input;
    	
        % generate block list
        info.blocklist = sprintf('|%s', D.data.name);
        info.blocklist = info.blocklist(2:end);
        
        info.blocklistc = regexp(info.blocklist,'\|','split');
    end
    
    set_info(obj,info);
end

function ui_plot(obj)
    
    info    = get_info(obj);
    
    if isfield(info,'block') && info.blockn>0
        
        block = info.input.data(info.blockn).value;

        if xs_exist(block,'WRD')
            WRD     = xs_get(block,'WRD');
            dat     = xs_get(WRD,info.data);
            ax      = get_axis(obj);

            if xs_exist(block,'axes')
                % axes info available

                axs     = xs_get(block,'axes');

                t = xs_get(axs,'time');
                f = xs_get(axs,'frequency');

                if size(dat,2)>1
                    surf(ax,t,f,dat'); shading flat;
                    ylabel('frequency [Hz]');
                    set(gca,'XLim',minmax(t),'YLim',minmax(f));
                else
                    plot(ax,t,dat);
                    set(gca,'XLim',minmax(t));
                end

                set(ax,'XTickLabel',datestr(get(ax,'XTick'),'dd-mmm-yyyy'));

                xlabel('time');
            else
                % no axes info available

                if size(dat,2)>1
                    surf(ax,dat'); shading flat;
                    set(gca,'XLim',[1 size(dat,1)],'YLim',[1 size(dat,2)]);
                else
                    plot(ax,dat);
                    set(gca,'XLim',[1 size(dat,1)]);
                end
            end

            try
                loc = xs_get(block,'W3H.LOC');

                if iscell(loc)
                    loc = loc{1};
                end

                title(loc);
            end
        end
    end
    
end

function vars = get_selected(obj,name)
    vars = get(get_obj(obj, name), 'String');
    idx  = min(size(vars,1),get(get_obj(obj, name), 'Value'));
    
    set(get_obj(obj, name), 'Value', idx);
    
    if ~isempty(idx) && any(idx>0)
        vars = vars(idx,:);
        vars = strtrim(num2cell(vars, 2));
    end
end

function ax = get_axis(obj)
    pobj = get_pobj(obj);
    ax = findobj(pobj, 'Type', 'Axes', 'Tag', '');
end

function pobj = get_pobj(obj)
    if strcmpi(get(obj, 'Tag'), 'donar_dia_view')
        pobj = obj;
    else
        pobj = get_pobj(get(obj, 'Parent'));
    end
end

function obj = get_obj(obj, name)
    pobj = get_pobj(obj);
    obj = findobj(pobj, 'Tag', name);
end

function info = get_info(obj)
    pobj = get_pobj(obj);
    info = get(pobj, 'userdata');
end

function set_info(obj, info)
    pobj = get_pobj(obj);
    set(pobj, 'userdata', info);
end