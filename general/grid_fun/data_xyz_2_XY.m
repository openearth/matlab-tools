function [X, Y, Z] = data_xyz_2_XY(varargin)
%DATA_XYZ_2_XY  Script to transform xyz column data to X, Y and Z grids
%

% --------------------------------------------------------------------
% Copyright (C) 2004-2009 Van Oord Dredging and Marine Contractors
% Version:      Version 1.0, October 2009
%     Mark van Koningsveld
%
%     mrv@vanoord.com
%
%     Environmental Engineering Department
%     Van Oord Dredging and Marine Contractors
%     Watermanweg 64
%     2628CN Rotterdam
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

%% settings
% defaults
OPT = struct(...
    'data', [], ...         
    'filename', [], ...  
    'cellsize_x', [], ...
    'cellsize_y', [], ...
    'datathinning', 1 ...
    );

% overrule default settings by property pairs, given in varargin
OPT = setProperty(OPT, varargin{:});

if isempty(OPT.data)
    data = load(OPT.filename);
else
    data = OPT.data;
end

if isempty(OPT.cellsize_x)
    diffs = diff(data(:,1));
    OPT.cellsize_x = min(abs(diffs(diffs~=0)));
end
if isempty(OPT.cellsize_y)
    diffs = diff(data(:,2));
    OPT.cellsize_y = min(abs(diffs(diffs~=0)));
end

minx = min(data(:,1));
maxx = max(data(:,1));
miny = min(data(:,2));
maxy = max(data(:,2));

% generate x and y vectors spanning the fixed map extents
x         = minx: OPT.cellsize_x*OPT.datathinning:maxx;
x         = roundoff(x,6); maxx =  roundoff(maxx,6);
if x(end)~= maxx; x = [x maxx];end % make sure maxx is included as a point

y         = maxy:-OPT.cellsize_y*OPT.datathinning:miny; % thinning runs from the lower left corner upward and right
y         = roundoff(y,6); miny =  roundoff(miny,6);
if y(end)~=miny; y = [y miny];end % make sure miny is included as a point

nrcols    = max(size(x));
nrofrows  = max(size(y));

% create the dummy X, Y, Z and Ztemps grids
X      = ones(nrofrows,1); X=X*x;      %X = roundoff(X, 6); - no longer needed if roundoff is already called above
Y      = ones(1,nrcols);   Y=y'*Y;     %Y = roundoff(Y, 6); - no longer needed if roundoff is already called above 
Z      = ones(size(X));    Z(:,:)=nan;

% clear unused variables to save memory
clear x y minx maxx miny maxy

[idX, idY] = find(ismember(X,data(:,1)) & ismember(Y,data(:,2)));
for i = 1:length(data(:,1))
    Z(idX(i),idY(i)) = data(i,3);
end

