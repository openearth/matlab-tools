function xb_gui_loaddata(obj, event)
%XB_GUI_LOADDATA  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_gui_loaddata(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_gui_loaddata
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
% Created: 06 Jan 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% load data

pobj = findobj('tag', 'xb_gui');

if exist('obj', 'var')
    switch get(obj, 'tag')
        case 'button_new'

            % create new model
            S = struct( ...
                'model', xb_generate_model, ...
                'runs', {{}}, ...
                'externals', struct( ...
                    'bathy', {{}}, ...
                    'hydro', {{}} ...
                ) ...
            );

            set(pobj, 'userdata', S);

        case 'button_open'
            [fname fpath] = uigetfile({'*.mat' 'Saved model setup (*.mat)'}, 'Open Model Setup');

            if fname
                set(pobj, 'userdata', load(fullfile(fpath, fname)));
            end
            
        case 'button_load'
            [fname fpath] = uigetfile({'*.txt' 'XBeach parameter file (*.txt)'}, 'Load Model');

            if fname
                S = struct();
                S.model = xb_read_input(fullfile(fpath, fname));
                set(pobj, 'userdata', S);
            end
    end
end

S = get(pobj, 'userdata');

%% check data

if ~isfield(S, 'model'); S.model = {}; end;
if ~isfield(S, 'runs'); S.runs = {}; end;
if ~isfield(S, 'externals'); S.externals = struct('bathy', {{}}, 'hydro', {{}}); end;

set(pobj, 'userdata', S);

%% enable gui

if xb_check(S.model)
    xb_gui_enable(pobj);
else
    return;
end

%% fill model setup tab
    
% empty setup tab
cla(findobj(pobj, 'tag', 'ax_1'));
cla(findobj(pobj, 'tag', 'ax_2'));

set(findobj(pobj, 'tag', 'wavesettings'), 'data', {});
set(findobj(pobj, 'tag', 'surgesettings'), 'data', {});
set(findobj(pobj, 'tag', 'settings'), 'data', {});

% bathy
cobj = findobj(pobj, 'tag', 'ax_1');
bathy = xb_input2bathy(S.model);
[x y z] = xb_get(bathy, 'xfile', 'yfile', 'depfile');
if min(size(z)) <= 3
    plot(cobj, mean(x, 1), mean(z, 1), '-k');
    
    set(cobj, 'xlim', [min(min(x)) max(max(x))], 'ylim', [min(min(z)) max(max(z))]);
    
    set(findobj(pobj, 'tag', 'databutton_3'), 'value', false, 'enable', 'off');
else
    pcolor(cobj, x, y, z);
    shading(cobj, 'flat');
    colorbar('peer', cobj);
    
    set(cobj, 'xlim', [min(min(x)) max(max(x))], 'ylim', [min(min(y)) max(max(y))]);
    
    set(findobj(pobj, 'tag', 'databutton_3'), 'enable', 'on');
end

% bcfile
cobj = findobj(pobj, 'tag', 'wavesettings');
bc = xb_get(S.model, 'bcfile');

if xb_check(bc)
    [f fi] = setdiff({bc.data.name}, {'type'});
    set(cobj, 'rowname', f);
    nt = max(cellfun('length', {bc.data(fi).value}));

    data = cell(1, nt);
    for j = 1:length(f)
        v = bc.data(fi(j)).value;

        if isscalar(v)
            v = repmat(v, 1, nt);
        end

        data(j,:) = num2cell(v);

        bc.data(fi(j)).value = v;
    end

    set(cobj, 'data', data, 'columneditable', [false true(1,nt)]);

    % plot
    t = cumsum(xb_get(bc, 'duration')); t = t - t(1);
    ax = findobj(pobj, 'tag', 'ax_2'); hold on;
    plot(ax, t, xb_get(bc, 'Hm0'), '-og');
    plot(ax, t, xb_get(bc, 'Tp'), '-ob');
end

% zs0file
time = 0;
cobj = findobj(pobj, 'tag', 'surgesettings');
zs0 = xb_get(S.model, 'zs0file');

if xb_check(zs0)
    nt = max(cellfun('length', {zs0.data.value}));

    time = xb_get(zs0, 'time');
    tide = xb_get(zs0, 'tide');
    
    data = num2cell(time');
    data(2:size(tide,2)+1,:) = num2cell(tide');
    
    set(cobj, 'data', data, 'columneditable', true(1,nt));

    % plot
    ax = findobj(pobj, 'tag', 'ax_2'); hold on;
    plot(ax, time, tide, '-or');
end

% zs0
zs0 = xb_get(S.model, 'zs0');

if ~isempty(zs0) && ~isnan(zs0)
    data = get(cobj, 'data');

    nt = max(1,size(data,2));
    zs0 = num2cell(repmat(zs0, 1, nt));

    if size(data,1) > 1
        data(3,:) = zs0;
    else
        data(2,:) = zs0;
    end
    
    set(cobj, 'data', data, 'columneditable', true(1,nt));

    % plot
    ax = findobj(pobj, 'tag', 'ax_2'); hold on;
    plot(ax, time, [zs0{:}], '-or');
end

% fill settings tab
fields = {S.model.data.name};
for i = 1:length(fields)
    if ~ismember(fields{i}, {'xfile', 'yfile', 'depfile', 'nx', 'ny', 'vardx', ...
            'posdwn', 'alpha', 'xori', 'yori', 'instat', 'swtable', 'dtbc', ...
            'rt', 'bcfile', 'zs0', 'zs0file'})
        cobj = findobj(pobj, 'tag', 'settings');

        data = get(cobj, 'data');
        data(size(data,1)+1,:) = {fields{i} S.model.data(i).value};
        set(cobj, 'data', data);
    end
end

%% fill run tab

cobj = findobj(pobj, 'tag', 'run_history');

data = {};

c = 1;
for i = 1:length(S.runs)
    if xb_check(S.runs{i})
        r = S.runs{i};
        
        data(c,:) = { ...
            xb_get(r, 'id'), ...
            r.date, ...
            xb_get(r, 'name'), ...
            xb_get(r, 'path'), ...
            xb_get(r, 'nodes'), ...
            xb_get(r, 'binary'), ...
            xb_exist(r, 'ssh')
        };
    
        c = c + 1;
    end
end

set(cobj, 'data', data);
