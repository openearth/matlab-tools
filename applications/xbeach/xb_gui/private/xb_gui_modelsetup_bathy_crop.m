function xb_gui_modelsetup_bathy_crop(obj, event)
%XB_GUI_MODELSETUP_BATHY_CROP  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_gui_modelsetup_bathy_crop(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_gui_modelsetup_bathy_crop
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

%% set crop

    pobj = findobj('tag', 'xb_gui');
    mobj = findobj(pobj, 'tag', 'ax_1');
    
    if get(obj, 'value')
        xb_gui_dragselect(mobj, 'select', true, 'fcn', @cropdata);
    else
        xb_gui_dragselect(mobj, 'select', false);
        
        cobj = findobj(mobj, 'tag', 'crop');
        if ~isempty(cobj)
            S = get(pobj, 'userdata');
            bathy = xb_input2bathy(S.model);

            [x y z] = xb_get(bathy, 'xfile', 'yfile', 'depfile');

            pos = get(cobj, 'position');
            ix = any(x>=pos(1)&x<=pos(1)+pos(3), 1);
            iy = any(y>=pos(2)&y<=pos(2)+pos(4), 2);
            x = x(iy,ix); y = y(iy,ix); z = z(iy,ix);

            bathy = xb_set(bathy, 'xfile', x, 'yfile', y, 'depfile', z);
            bathy = xb_bathy2input(bathy);
            bathy = xb_set(bathy, 'nx', size(z,2), 'ny', size(z,1));

            S.model = xb_join(S.model, bathy);
            set(pobj, 'userdata', S);

            xb_gui_loaddata;
        end
    end
    
    set(get(mobj, 'children'), 'hittest', 'off');
end

function cropdata(obj, event, aobj, xpol, ypol)
    pos = [min(xpol) min(ypol) max(abs(diff(xpol))) max(abs(diff(ypol)))];
    
    cobj = findobj(aobj, 'tag', 'crop');
    if isempty(cobj);
        rectangle('position', pos, 'tag', 'crop', 'parent', aobj);
    else
        set(cobj, 'position', pos);
    end
end