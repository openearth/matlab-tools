function xb = xb_grid_delft3d(varargin)
%XB_GRID_DELFT3D  Convert XBeach grid to Delft3D and back
%
%   Accepts a path to an XBeach model or an XBeach input structure. Either
%   way it returns an XBeach structure with the grid definition swapped
%   from XBeach format to Delft3D format or vice versa. In case a path is
%   given, the written model is updated as well.
%
%   Syntax:
%   xb = xb_grid_delft3d(varargin)
%
%   Input:
%   varargin  = Either an XBeach input structure or path to XBeach model
%
%   Output:
%   xb        = Modified XBeach input structure
%
%   Example
%   xb_grid_delft3d('path_to_model/')
%   xb_grid_delft3d('path_to_model/')
%   xb = xb_grid_delft3d('path_to_model/')
%   xb = xb_grid_delft3d(xb)
%
%   See also xb_generate_grid

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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
% Created: 02 Nov 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% check function availability

if exist('wlgrid','file') ~= 2 || exist('wldep','file') ~= 2
    error('Functions wlgird and/or wldep are not available. Please include the Deltf3D toolbox.');
end

%% read input

write = false;

if ~isempty(varargin)
    
    if ischar(varargin{1}) && (exist(varargin{1}, 'dir') ||  exist(varargin{1}, 'file'))
        write = true;
        xb = xb_read_input(varargin{1});
    elseif xb_check(varargin{1})
        xb = varargin{1};
    else
        return;
    end
    
    if xb_check(xb)
        if xb_exist(xb, 'xyfile')
            [xy z ne]   = xb_get(xb, 'xyfile.data', 'depfile.depfile', 'ne_layer.ne_layer');
            
            xb = xb_del(xb, 'xyfile');
            xb = xb_set(xb, 'gridform', 'xbeach');
            
            [x_xb y_xb] = wlgrid2xb(xy);
            
            xb = xb_set(xb, 'xfile', xb_set([], 'xfile', x_xb), 'yfile', xb_set([], 'yfile', y_xb));
            
            xb = xb_set(xb, 'depfile.depfile', wldep2xb(z, size(x_xb)));
            
            if ~isempty(ne)
                xb = xb_set(xb, 'ne_layer.ne_layer', wldep2xb(ne, size(x_xb)));
            end
        else
            [x y z ne]  = xb_input2bathy(xb);
            [xori yori] = xb_get(xb, 'xori', 'yori');
            
            xb = xb_del(xb, 'xfile', 'yfile', 'xori', 'yori');
            xb = xb_set(xb, 'gridform', 'delft3d');
            
            if ~isempty(xori) && ~isempty(yori)
                x_d3d = x+xori;
                y_d3d = y+yori;
            else
                x_d3d = x;
                y_d3d = y;
            end
            
            xb = xb_set(xb, 'xyfile', xb_set([], 'data', xb2wlgrid(x_d3d,y_d3d)));

            xb      = xb_set(xb, 'depfile.depfile', xb2wldep(z));
            
            if ~isempty(ne)
                xb      = xb_set(xb, 'ne_layer.ne_layer', xb2wldep(ne));
            end
        end
        
        if write
            xb_write_input(varargin{1}, xb);
        end
    end
end

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function z = add_dummy_columns(z)
    z  = [z  -999*ones(  size(z,1),1); ...
             -999*ones(1,size(z,2)+1)     ];
end

function z = remove_dummy_columns(z)
    if all(z(:,end)==-999); z = z(:,1:end-1); end;
	if all(z(end,:)==-999); z = z(1:end-1,:); end;
end

function xyfile = xb2wlgrid(x,y)

    fname = [tempname '.grd'];
    xyfile = '';
            
    if wlgrid('write',fname,x',y')

        fid = fopen(fname,'r');
        xyfile = fread(fid,'*char');
        fclose(fid);

        delete(fname);
    end
end

function depfile = xb2wldep(z)

    fname = tempname;
    depfile = '';
    
    z = add_dummy_columns(z);
            
    if wldep('write',fname,z')

        fid = fopen(fname,'r');
        depfile = fread(fid,'*char');
        fclose(fid);

        delete(fname);
    end
end

function [x y] = wlgrid2xb(xyfile)

    fname = tempname;
            
    fid = fopen(fname,'w');
    fwrite(fid,xyfile);
    fclose(fid);

    xyfile = wlgrid('read',fname);

    delete(fname);

    if isstruct(xyfile)
        x = xyfile.X';
        y = xyfile.Y';
    else
        x = [];
        y = [];
    end
end

function z = wldep2xb(z, sz)
    c = textscan(z, '%f');
    z = reshape(c{1}, fliplr(sz)+1)';
    z = remove_dummy_columns(z);
end
