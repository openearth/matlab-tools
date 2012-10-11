function [q,bi] = quat2net(x,y)
%QUAT2NET quadrangulates a mesh into a network
%
% [q,bi] = quat2net(x,y)
%
% where x and y are plaid matrices as returned by NDGRID
% or MESHGRID, q and bi are integer pointer arrays into
% vectors [x(:),y(:)]. q indexes the perimeter of quadrangles,
% bi indexes the separate face segment after removal of overlap
% between adjacenent quadrangles. % q and bi fail when you swap 
% x and y afterwards, for instance upon interchanging 
% NDGRID and MESHGRID arrays.
%
% Example:
%
%   subplot(1,2,1)
%   [x,y]=ndgrid(1:3,1:4);
%   x([3 10])=nan;y([3 10])=nan;% nans are taken care off, and not included
%   [q,bi]=quat2net(x,y);
%   pcolor(x,y,x.*0);
%   hold on
%   poly_bi_plot(bi,x,y,'r--')
%   
%   subplot(1,2,2)
%   [xm,ym]=meshgrid(1:3,1:4);
%   xm([3 10])=nan;ym([3 10])=nan;% nans are taken care off, and not included
%   [qm,bim]=quat2net(xm,ym);
%   pcolor(xm,ym,xm.*0);
%   hold on
%   poly_bi_plot(bim,xm,ym,'r--')
%
%See also: quat, dflowfm, poly_bi_unique

%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Gerben de Boer
%
%       <g.j.deboer@deltares.nl>
%
%       Deltares
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

q  = quat(x,y);
bi = repmat(0,[size(q,1)*4 2]);
for iq=1:size(q,1)
   bi((iq-1)*4+1:iq*4,:) = [q(iq,:); q(iq,[2 3 4 1])]';
end
bi = poly_bi_unique(bi);

