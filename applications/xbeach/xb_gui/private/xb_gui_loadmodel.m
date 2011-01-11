function xb_gui_loadmodel(obj, event)
%XB_GUI_LOADMODEL  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_gui_loadmodel(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_gui_loadmodel
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
% Created: 10 Jan 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% load model in gui struct

pobj = findobj('tag', 'xb_gui');
S = get(pobj, 'userdata');

if xb_check(S.model)
    bathy = xb_input2bathy(S.model);
    [x y z] = xb_get(bathy, 'xfile', 'yfile', 'depfile');
    S.modelsetup.bathy.x = x;
    S.modelsetup.bathy.y = y;
    S.modelsetup.bathy.z = z;

    waves = xb_get(S.model, 'bcfile');
    S.modelsetup.hydro.waves = cell2struct({waves.data.value}, {waves.data.name}, 2);

    [time tide zs0] = xb_get(S.model, 'zs0file.time', 'zs0file.tide', 'zs0');
    S.modelsetup.hydro.surge = cell2struct({time' tide' zs0}, {'time' 'tide' 'zs0'}, 2);

    fields = {S.model.data.name};
    for i = 1:length(fields)
        if ~ismember(fields{i}, {'xfile', 'yfile', 'depfile', 'nx', 'ny', 'vardx', ...
                'posdwn', 'alpha', 'xori', 'yori', 'instat', 'swtable', 'dtbc', ...
                'rt', 'bcfile', 'zs0', 'zs0file'})
            S.modelsetup.settings.(fields{i}) = S.model.data(i).value;
        end
    end
    
    set(pobj, 'userdata', S);
end
