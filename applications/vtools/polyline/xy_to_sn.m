function [sp, np] = xy_to_sn(xv, yv, xp, yp); 
%xy_to_sn Conversion of spatial coordinates to channel coordinates
%
%   Conversion of x, y coordinates to channel following (s) and channel
%   perpendicular (n)
%
%   Syntax:
%   [sp, np] = xy_to_sn(xv, yv, xp, yp); 
%
%   Input: 
%   xv  = vector with x coordinates of channel axis 
%   yv  = vector with y coordinates of channel axis 
%   xp  = spatial x coordinates to be converted 
%   yp  = spatial y coordinates to be converted 
%
%   Output:
%   sp  = channel following coordinates 
%   np  = channel perpendicular coordinates 
%
%   Example
%
% xv = [-3:0.5:3].';
% yv = xv.^3/9;
% 
% xp = [1.2,2.1];
% yp = [0, 3];
% 
% [sp,np] = xy_to_sn(xv,yv,xp,yp);
% [sv,nv] = xy_to_sn(xv,yv,xv,yv);
% 
% subplot(211); 
% plot(xv,yv,'.-'); 
% hold on; 
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

sz_x = size(xp);
sz_y = size(yp);
assert(max(abs(sz_x-sz_y)==0),'xp and yp should have the same size')

% transform into column vectors
xp = xp(:); 
yp = yp(:);

%get distances
dxv = diff(xv);
dyv = diff(yv);

%get mid points of channel axis
xmv = xv(1:end-1) + 0.5*dxv;
ymv = yv(1:end-1) + 0.5*dyv;

batch_size = 1000; 

lenp = length(xp);
min_dist = NaN*ones(lenp,1);
min_idx = NaN*ones(lenp,1);

for kstart = 1:batch_size:length(xp)
    kend = min(kstart+batch_size-1,lenp);
    % get distance matrix 
    dist_mat = (xmv-xp(kstart:kend)).^2 + (ymv-yp(kstart:kend)).^2; 
    [min_dist_local, min_idx_local] = min(dist_mat,[],2);
    
    min_dist(kstart:kend) = min_dist_local;
    min_idx(kstart:kend) = min_idx_local;
end

% get distance along channel 
sv = [0,cumsum(sqrt(dxv.^2 + dyv.^2))];
% get angle along channel 
angv = angle(dxv + i*dyv);    

% determine nearest point 
x_nearest = xv(min_idx);
y_nearest = yv(min_idx);
ang_nearest = angv(min_idx);
s_nearest = sv(min_idx);

% determine location relative to nearest point
x_shift = xp - x_nearest(:); 
y_shift = yp - y_nearest(:); 

z = (x_shift + i*y_shift).*exp(-i*ang_nearest(:));

% compute the channel perpendicular and following coordinates
np = -imag(z);
sp = real(z) + s_nearest(:);

% reformat the variables into the original size
np = reshape(np,sz_x);
sp = reshape(sp,sz_x);

end