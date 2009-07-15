function [tri,x1,y1,z1] = delaunay_simplified(x,y,z,tolerance,maxSize,maxIterations)
% DELAUNAY_SIMPLIFIED makes a simplified delaunay triangulated mesh
% 
% For creating meshes that resemble a more complex mesh to a certain
% degree (specified by tolernace;, the maximum error there may exist
% between the final grid and the original datapoints.
%
% All nan edges withing the grid are used in triangulation, but no 
% triangles are created where nan's are available.   
%
% The script is does not find an optimum solution, but works well enough in
% reducing triangles.
%
% Eaxample (play with different values for tolerance:
%
%     url = 'http://opendap.deltares.nl:8080/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB119_3534.nc';
%     x = nc_varget(url,'x');
%     y = nc_varget(url,'y');
%     z = nc_varget(url,'z',[0,0,0],[1,-1,-1]);
%     [x,y] = meshgrid(x,y);
% 
%     disp(['elements: ' num2str(sum(~isnan(z(:))))]);
%     tolerance = .5;  maxSize = 100000;
%     [tri,x2,y2,z2] = delaunay_simplified(x,y,z,tolerance,maxSize);
%     [lat,lon] = convertCoordinatesNew(x2,y2,EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
%     z2= (z2+15)*2;
%     KMLtrisurf(tri,lat,lon,z2)
%
% See also: delaunay, trisurf, KMLtrisurf 

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Thijs Damsma
%
%       Thijs.Damsma@deltares.nl	
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
% $Keywords: $

%% find convex hull of not nan z values

A = ~isnan(z);
%left
Aleft = [A(:,2:end) false(size(A,1),1)];
%right
Aright = [false(size(A,1),1) A(:,1:end-1)];
% up
Aup = [ A(2:end,:);false(1,size(A,2))];
% down
Adown = [false(1,size(A,2));A(1:end-1,:)];

A = A|Aleft|Aright|Aup|Adown;



xi = x(A);
yi = y(A);
zi = z(A);

ind = find(isnan(zi));
zi(isnan(zi)) = ceil(max(z(:))+2*tolerance+15);

%% assign start values
ind = [ind; convhull(xi,yi)];
ind = unique(ind);
x1 = xi(ind);
y1 = yi(ind);
z1 = zi(ind);

%% iteration
error = inf;
iteration = 0;
tri2 = 0;
while error>tolerance && size(tri2,1)<maxSize && iteration<maxIterations
    iteration = iteration+1;
    % Triangularize the data

    tri2 = delaunayn([x1 y1]);

    % Find the nearest triangle (t)
    t = tsearch(x1,y1,tri2,xi,yi);

    % Only keep the relevant triangles.
    out = find(isnan(t));
    if ~isempty(out), t(out) = ones(size(out)); end
    tri = tri2(t,:);

    % Compute Barycentric coordinates (w).  P. 78 in Watson.
    del = (x1(tri(:,2))-x1(tri(:,1))) .* (y1(tri(:,3))-y1(tri(:,1))) - ...
        (x1(tri(:,3))-x1(tri(:,1))) .* (y1(tri(:,2))-y1(tri(:,1)));
    w(:,3) = ((x1(tri(:,1))-xi).*(y1(tri(:,2))-yi) - (x1(tri(:,2))-xi).*(y1(tri(:,1))-yi)) ./ del;
    w(:,2) = ((x1(tri(:,3))-xi).*(y1(tri(:,1))-yi) - (x1(tri(:,1))-xi).*(y1(tri(:,3))-yi)) ./ del;
    w(:,1) = ((x1(tri(:,2))-xi).*(y1(tri(:,3))-yi) - (x1(tri(:,3))-xi).*(y1(tri(:,2))-yi)) ./ del;
    w(out,:) = zeros(length(out),3);

    z3 = z1(:).'; % Treat z as a row so that code below involving
    % z(tri) works even when tri is 1-by-3.
    z2 = sum(z3(tri) .* w,2);

    % find triangles that need to be refined.

    error = zi-z2;
%     t_unique = unique(t(error>tolerance));

    
    temp = 0.1/ceil(max(abs(error)));
    M = t+error*temp;
    [M,ind] = sort(M);
    addInd = ind([true;diff(M)>.3]|[diff(M)>.3;true]) ;
    addInd = addInd(abs(error(addInd))>tolerance);
    addInd = unique(addInd);
    %add newCoords
    x1 = [x1; xi(addInd)];
    y1 = [y1; yi(addInd)];
    z1 = [z1; zi(addInd)];
    
    [error,ind] = max(abs(error));
  
    disp(sprintf('iteration: % 3d  Number of triangles:% 6d  error = % 6.2f at index % 4d',...
        iteration,size(tri2,1),error,ind));
end


tri = delaunay(x1,y1);

%% find triangles with nan values inside
ind = ismember(tri,find(z1==ceil(max(z(:))+2*tolerance+15)));
ind = any(ind,2);

%% delete triangles with nan values
tri(ind,:) = [];
disp(sprintf('Completed,  % 6d triangles created',...
        size(tri,1)));

