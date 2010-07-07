function [crossing_x,crossing_y,crossing_z,crossing_d] = grid_orth_getDataOnLine(X,Y,Z,xi,yi)
%GRID_ORTH_GETDATAONLINE  ...
%
% X and Y are expected to be created with meshgrid or similar
%
% See also: grid_orth_getFixedMapOutlines, grid_orth_createFixedMapsOnAxes, 
%           grid_orth_identifyWhichMapsAreInPolygon, grid_orth_getDataFromNetCDFGrid

% --------------------------------------------------------------------
% Copyright (C) 2004-2009 Delft University of Technology
% Version:      Version 1.0, February 2004
%     Mark van Koningsveld
%
%     m.vankoningsveld@tudelft.nl
%
%     Hydraulic Engineering Section
%     Faculty of Civil Engineering and Geosciences
%     Stevinweg 1
%     2628CN Delft
%     The Netherlands
%
% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Lesser General Public
% License as published by the Free Software Foundation; either
% version 2.1 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
% USA
% --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$

%% input
if X(1,1)>X(1,end)
    X = fliplr(X);
    Y = fliplr(Y);
    Z = fliplr(Z);
end

if Y(1,1)>Y(end,1)
    X = flipud(X);
    Y = flipud(Y);
    Z = flipud(Z);
end

if xi(1)>xi(2)
    xi      = xi([2 1]);
    yi      = yi([2 1]);
    reverse = true;
else
    reverse = false;
end
%% crop area to search for crossings to line
temp = X>=min(xi)&X<=max(xi)&Y>=min(yi)&Y<=max(yi);
mm   = max(1,find(any(temp,2),1,'first')-1):1:min(size(X,1),find(any(temp,2),1,'last')+1);
nn   = max(1,find(any(temp,1),1,'first')-1):1:min(size(X,2),find(any(temp,1),1,'last')+1);

%% lengthen search line

dx  = xi(2) - xi(1);
dy  = yi(2) - yi(1);
xi2 = xi + [-dx dx]*3;
yi2 = yi + [-dy dy]*3;

%% pre allocate
crossing_x = nan(numel(mm)+numel(nn),1);
crossing_y = nan(numel(mm)+numel(nn),1);
crossing_z = nan(numel(mm)+numel(nn),1);

jj = 0;

% find all locations of crossings with rows
for ii = mm
    P = InterX([X(ii,:);Y(ii,:)],[xi2;yi2]);
    if ~isempty(P)
        jj = jj+1;
        crossing_x(jj) = P(1,1);
        crossing_y(jj) = P(2,1);
        a = find(X(ii,:)<=crossing_x(jj),1, 'last');
        b = find(X(ii,:)>=crossing_x(jj),1,'first');
        if a~=b
            c = (crossing_x(jj) - X(ii,a))/(X(ii,b) - X(ii,a));
        else
            c = 1;
        end
        crossing_z(jj) = Z(ii,a) * (1-c) + Z(ii,b) * c;
    end
end

% find all locations of crossings with columns
for ii = nn
    P = InterX([X(:,ii)';Y(:,ii)'],[xi2;yi2]);
    if ~isempty(P)
        jj = jj+1;
        crossing_x(jj) = P(1,1);
        crossing_y(jj) = P(2,1);
        a = find(Y(:,ii)<=crossing_y(jj),1, 'last');
        b = find(Y(:,ii)>=crossing_y(jj),1,'first');
        if a~=b
            c = (crossing_y(jj) - Y(a,ii))/(Y(b,ii) - Y(a,ii));
        else
            c = 1;
        end
        crossing_z(jj) = Z(a,ii) * (1-c) + Z(b,ii) * c;
    end
end
%% delete nan data
crossing_z(isnan(crossing_x)) = [];
crossing_y(isnan(crossing_x)) = [];
crossing_x(isnan(crossing_x)) = [];

%% sort

 crossing_d = ((crossing_x - xi(1)).^2 + (crossing_y-yi(1)).^2).^.5;
 
          a = find(crossing_x<=min(xi));
[dummy, b]  = min(crossing_d(a));
          a = a(b);
crossing_x1 =  crossing_x(a);
crossing_y1 =  crossing_y(a);
crossing_z1 =  crossing_z(a);
crossing_d1 = -crossing_d(a);

          a = find(crossing_x>=max(xi));
[dummy, b]  = min(crossing_d(a));
          a = a(b);
crossing_x2 =  crossing_x(a);
crossing_y2 =  crossing_y(a);
crossing_z2 =  crossing_z(a);
crossing_d2 =  crossing_d(a);

[dummy,ind] = sort(crossing_d);
        ind = ind(crossing_x(ind)>min(xi)&crossing_x(ind)<max(xi));

if ~isempty(crossing_x1) & ~isempty(ind)
    a = (crossing_x(ind(1)) - min(xi))/(crossing_x(ind(1)) - crossing_x1);
    crossing_x1 = crossing_x1*a + crossing_x(ind(1))*(1-a);
    crossing_y1 = crossing_y1*a + crossing_y(ind(1))*(1-a);
    crossing_z1 = crossing_z1*a + crossing_z(ind(1))*(1-a);
    crossing_d1 = 0;
end

if ~isempty(crossing_x2) & ~isempty(ind)
    a = (crossing_x(ind(end)) - max(xi))/(crossing_x(ind(end)) - crossing_x2);
    crossing_x2 = crossing_x2*a + crossing_x(ind(end))*(1-a);
    crossing_y2 = crossing_y2*a + crossing_y(ind(end))*(1-a);
    crossing_z2 = crossing_z2*a + crossing_z(ind(end))*(1-a);
    crossing_d2 = ((xi(2) - xi(1)).^2 + (yi(2)-yi(1)).^2)^.5;
end
crossing_x    =[crossing_x1; crossing_x(ind); crossing_x2];
crossing_y    =[crossing_y1; crossing_y(ind); crossing_y2];
crossing_z    =[crossing_z1; crossing_z(ind); crossing_z2];
crossing_d    =[crossing_d1; crossing_d(ind); crossing_d2];

if reverse 
    crossing_x = flipud(crossing_x);
    crossing_y = flipud(crossing_y);
    crossing_z = flipud(crossing_z);
    crossing_d = ((crossing_x - xi(2)).^2 + (crossing_y-yi(2)).^2).^.5;
end
