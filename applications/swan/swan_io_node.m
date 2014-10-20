function varargout = swan_io_node(cmd,varargin)
%SWAN_IO_NODE  read/write SWAN UNSTRUCTURED node file
%
% reads Triangle node file as described in
% http://www.cs.cmu.edu/afs/cs/project/quake/public/www/triangle.node.html
%
%   [x,y,<b,<p>>] = swan_io_node('read',filename)
%
% where x,y are 1D vectors, 
% b is the optional 1D boundary marker vector,
% and p is a 2D property matrix.
%
% See also: SWAN_IO_ELE, trisurf, triplot, triangular

%   --------------------------------------------------------------------
%   (c) Adapted from example plotgrid.m from http://swan.tudelft.nl
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

% $Id: swan_io_bot.m 4776 2011-07-07 15:33:33Z boer_g $
% $Date: 2011-07-07 17:33:33 +0200 (Thu, 07 Jul 2011) $
% $Author: boer_g $
% $Revision: 4776 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/swan/swan_io_bot.m $

if     strcmp(cmd,'read') | ...
       strcmp(cmd,'load')
       
% http://www.cs.cmu.edu/afs/cs/project/quake/public/www/triangle.node.html
       
    nodefile = varargin{1};
    fid = fopen(nodefile);                        % load TRIANGLE vertex based connectivity file
    [nnode] = fscanf(fid,'%i',[1 4]);             % get number of nodes
    ncol = 3+nnode(3)+nnode(4);                   % specify number of columns in nodefile
    data = fscanf(fid,'%f',[ncol nnode(1)])';     % get data
    x=data(:,2); y=data(:,3); b=data(:,end);      % get coordinates
    p=data(:,4:end-1);
    fclose(fid);
    
    varargout = {x,y,b,p};

elseif strcmp(cmd,'write')


end   

%% EOF