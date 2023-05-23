function [xp, yp] = xy_to_sn(xv, yv, sp, np); 
%sn_to_xy Conversion of channel coordinates to spatial coordinates
%
%   Conversion of channel following (s) and channel
%   perpendicular (n) coordinates to x, y coordinates
%
%   Syntax:
%   [xp, yp] = xy_to_sn(xv, yv, sp, np); 
%
%   Input: 
%   xv  = vector with x coordinates of channel axis 
%   yv  = vector with y coordinates of channel axis 
%   sp  = channel following coordinates to be converted 
%   np  = channel perpendicular coordinates to be converted 
%
%   Output:
%   xp  = spatial x coordinates 
%   yp  = spatial y coordinates 
%
%   Example
%
% xv = [-3:0.5:3].';
% yv = xv.^3/9;
% 
% xpt = [1.2,2.1];
% ypt = [0, 3];
% 
% [sp,np] = xy_to_sn(xv,yv,xpt,ypt);
% [sv,nv] = xy_to_sn(xv,yv,xv,yv);
% [xp,yp] = sn_to_xy(xv,yv,sp,np)
% 
% subplot(211); 
% plot(xv,yv,'.-'); 
% hold on; 
% plot(xpt,ypt,'o');
% plot(xp,yp,'x');
% hold off;
% axis equal; 
% title('x,y coordinates')
% 
% subplot(212); 
% plot(sv,nv,'.-'); 
% hold on; 
% plot(sp,np,'x');
% hold off;
% axis equal; 
% title('s,n coordinates')


% interpolate to spline; 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2023 Deltares
%       ottevan
%
%       willem.ottevanger@deltares.nl
%
%       Boussinesqweg 1 2629 HV Delft
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
% Created: 12 May 2023
% Created with Matlab version: 9.11.0.1769968 (R2021b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

% %%
% OPT.keyword=value;
% % return defaults (aka introspection)
% if nargin==0;
%     varargout = {OPT};
%     return
% end
% % overwrite defaults with user arguments
% OPT = setproperty(OPT, varargin);
%% code
%
% transform into row vectors
xv = xv(:).'; 
yv = yv(:).'; 

sz_s = size(sp);
sz_n = size(np);
assert(max(abs(sz_s-sz_n)==0),'sp and np should have the same size')

% transform into column vectors
sp = sp(:); 
np = np(:);

%get distances
dxv = diff(xv);
dyv = diff(yv);

%get mid points of channel axis
xmv = xv(1:end-1) + 0.5*dxv;
ymv = yv(1:end-1) + 0.5*dyv;

% transfrom axis to channel coordinates
[sv,nv] = xy_to_sn(xv,yv,xv,yv);

%get channel distances
dsv = diff(sv);
dnv = diff(sv);

%get mid points of channel axis
smv = sv(1:end-1) + 0.5*dsv;
nmv = sv(1:end-1) + 0.5*dnv;

% get distance matrix 
dist_mat = (smv-sp).^2 + (nmv-sp).^2; 
[min_dist, min_idx] = min(dist_mat,[],2);

% get angle along channel 
angv = angle(dxv + i*dyv);    

% determine nearest point 
x_nearest = xv(min_idx);
y_nearest = yv(min_idx);
ang_nearest = angv(min_idx);
s_nearest = sv(min_idx);
n_nearest = nv(min_idx);

% determine location relative to nearest point
s_shift = sp - s_nearest(:); 
n_shift = np - n_nearest(:); 

z = (s_shift - i*n_shift).*exp(i*ang_nearest(:));

x_shift = real(z);
y_shift = imag(z);

% compute the channel perpendicular and following coordinates
xp = x_nearest(:) + x_shift(:); 
yp = y_nearest(:) + y_shift(:); 

% reformat the variables into the original size
xp = reshape(xp,sz_s);
yp = reshape(yp,sz_s);

end