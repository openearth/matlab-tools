function varargout = swan_io_node(cmd,varargin)
%SWAN_IO_ELE  read/write SWAN UNSTRUCTURED ele file
%
% reads Triangle node file as described in
% http://www.cs.cmu.edu/afs/cs/project/quake/public/www/triangle.ele.html
%
%   [tri,<ind,<p>>] = swan_io_ele('read',filename)
%
% where tri is the 2D connecvitiy matrix vectors, 
% ind is the optional element index,
% and p is a 2D property matrix.
%
% Example:
%
%    basename = 'test\bla';
%    nodefile = [basename '.node'];
%    elefile  = [basename '.ele'];
%
%    [x,y,b,p] = swan_io_node('read',nodefile); 
%    [tri,ind] = swan_io_ele ('read',elefile);
%
%    % plot mesh, switch off legend per lien segment
%    triplot(tri,x,y,'color',[.5 .5 .5],'handlevisibility','off');
%    hold on
%
%    % plot open boundary
%    TR = triangulation(tri, x,y);
%    fe = freeBoundary(TR)';
%    plot(x(fe),y(fe),'k','linewidth',2,'handlevisibility','off');
%
%    % plot open boundary values for assigning boundary conditions
%    bs = setxor(unique(b),0); % exclude 0
%    colors = [1 0 0; 0 1 0; 0 0 1];
%    for i=1:length(bs)
%        mask = b==bs(i);sum(mask);
%        plot(x(mask),y(mask),'.','color',colors(:,i),'Displayname',['b=',num2str(bs(i))])
%        hold on
%    end
%
%    legend show
%    axislat;tickmap('ll')
%    grid on
%    print2a4(basename,'v','w','-r200','o')
%
% See also: SWAN_IO_NODE, trisurf, triplot

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
       
    elefile = varargin{1};
    fid = fopen(elefile);                         % load TRIANGLE element based connectivity file
    [nelem] = fscanf(fid,'%i',[1 3]);             % get number of triangles
    ncol = 4+nelem(3);                            % specify number of columns in elefile
    tri = fscanf(fid,'%i',[ncol nelem(1)])';      % get connectivity table
    
    ind = tri(:,1);
    p   = tri(:,5:end);
    tri = tri(:,2:4); % last, inline replacement
    
    varargout = {tri,ind,p};

elseif strcmp(cmd,'write')


end   

%% EOF