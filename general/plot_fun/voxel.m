function varargout = voxel(varargin)
%VOXEL  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%       handle           = voxel(p)    
%       [faces,vertices] = voxel(x,y,z,p)
%
%       voxel(p)       where p is 3d logical object
%       voxel(x,y,z,p) where x y and z are
%                      1d vectors   will be internally meshgridded
%                      3d of size p    (center coordinates)
%                      3d of size(p+1) (corner coordinates)
%
%   Input:
%   varargin  = voxel(p)
%
%   Output:
%   varargout = handle to patch object
%               
%
%   Example
%
%       nn = 10.5;
%       [x,y,z] = deal(-nn:nn); 
%       [x,y,z] = meshgrid(x,y,z);
%       p = x.^2+y.^2+z.^2 < (nn-1)^2;
%       h = voxel(p);
%
%   See also
%
% TODO: make setproperty work, plot different colors

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Van Oord
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
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
% Created: 08 Feb 2012
% Created with Matlab version: 7.14.0.834 (R2012a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
OPT.triangles    = false;
OPT.plotSettings = {'facecolor','b'};
% OPT = setproperty(OPT,varargin{:});
% 
% if nargin==0;
%     varargout = OPT;
%     return;
% end
%% code

switch nargin
    case 1
        p = varargin{1};
        if ndims(p) ~= 3
            error
        end
        x = 0:size(p,2);
        y = 0:size(p,1);
        z = 0:size(p,3);
        [x,y,z] = meshgrid(x,y,z);
    case 4
        p = varargin{4};
        if ndims(p) ~= 3
            error
        end
        x = varargin{1};
        y = varargin{2};
        z = varargin{3};
    otherwise
        error
end

if all([isvector(x),isvector(y),isvector(z)])
    [x,y,z] = meshgrid(x,y,z);
else
    if ~isequal(size(x),size(y),size(z))
        error
    end
end
% x,y and z are equal zies
if size(p) + 1 ==  size(x)
    % ok
elseif size(p) == size(x)
    z =  permute(z,[2,3,1]);
    x = [2*x(:,1,:) -  x(:,2,:)  x  2*x(:,end,:) -  x(:,end-1,:)];
    y = [2*y(1,:,:) -  y(2,:,:); y; 2*y(end,:,:) -  y(end-1,:,:)];
    z = [2*z(:,1,:) -  z(:,2,:)  z 2*z(:,end,:)  -  z(:,end-1,:)];
    x = (x(:,1:end-1,:) + x(:,2:end,:))/2;
    y = (y(1:end-1,:,:) + y(2:end,:,:))/2; 
    z = (z(:,1:end-1,:) + z(:,2:end,:))/2;
    z =  permute(z,[3,1,2]);
else
    error;
end





% from here you need X,Y,Z which are all same size 3D. p is size(X,Y,Z) - 1
% in all dimesnions.  

%% dim1
faces = [];
for dim = 1:3;
    n = [0 0 0];
    n(dim) = 1;
    sides = false(size(p)+n);
    switch dim
        case 1
            sides(2:end-1,:,:) = diff(p,1,dim) ~= 0;
            sides([1 end],:,:) = p([1 end],:,:);
        case 2
            sides(:,2:end-1,:) = diff(p,1,dim) ~= 0;
            sides(:,[1 end],:) = p(:,[1 end],:);
        case 3
            sides(:,:,2:end-1) = diff(p,1,dim) ~= 0;
            sides(:,:,[1 end]) = p(:,:,[1 end]);
    end
    
    [s1,s2,s3,s4] = deal(false(size(x)));
    switch dim
        case 1
            s1(:,1:end-1,1:end-1) = sides;
            s2(:,1:end-1,2:end-0) = sides;
            s3(:,2:end-0,2:end-0) = sides;
            s4(:,2:end-0,1:end-1) = sides;
        case 2
            s1(1:end-1,:,1:end-1) = sides;
            s2(1:end-1,:,2:end-0) = sides;
            s3(2:end-0,:,2:end-0) = sides;
            s4(2:end-0,:,1:end-1) = sides;
        case 3
            s1(1:end-1,1:end-1,:) = sides;
            s2(1:end-1,2:end-0,:) = sides;
            s3(2:end-0,2:end-0,:) = sides;
            s4(2:end-0,1:end-1,:) = sides;
    end
    
    if OPT.triangles
        faces = [faces; [[find(s1) find(s2) find(s3)]; [find(s3) find(s4) find(s1)]]]; %#ok<AGROW>
    else
        faces = [faces; [find(s1) find(s2) find(s3) find(s4)]];
    end
end

[iV,~,iF] = unique(faces);
verts   = [x(iV) y(iV) z(iV)];
faces   = reshape(iF,size(faces));

switch nargout
    case 0
        patch('Faces',faces,'Vertices',verts,OPT.plotSettings{:});
    case 1
        varargout{1} = patch('Faces',faces,'Vertices',verts,OPT.plotSettings{:});
        view(3)
    case 2
        varargout{1} = faces;
        varargout{2} = verts;
end
