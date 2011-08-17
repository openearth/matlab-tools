function [X, Y, Z, Ztime] = rws_data2grid(mapurls, minx, maxx, miny, maxy, OPT)
error('This function is deprecated in favour of grid_orth_data2grid')
%RWS_DATA2GRID get data in fixed otrhogonal grid from bundle of netCDF files
%
%   [X, Y, Z, Ztime] = rws_data2grid(mapurls, minx, maxx, miny, maxy, <keyword,value>)
%
% See also: rws_createFixedMapsOnAxes, rws_createFixedMapsOnFigure,
%   rws_data2grid, rws_getDataFromNetCDFGrid, rws_getDataFromNetCDFGrid_test,
%   rws_getDataInPolygon, rws_getDataInPolygon_test, rws_getFixedMapOutlines,
%   rws_identifyWhichMapsAreInPolygon, rws_plotDataInPolygon

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

% generate x and y vectors spanning the fixed map extents

   x         = minx :  OPT.cellsize*OPT.datathinning : maxx;
   x         = roundoff(x,6); maxx =  roundoff(maxx,6);
   if x(end)~= maxx; x = [x maxx];end % make sure maxx is included as a point
   
   y         = maxy : -OPT.cellsize*OPT.datathinning : miny; % thinning runs from the lower left corner upward and right
   y         = roundoff(y,6); miny =  roundoff(miny,6);
   if y(end)~=miny; y = [y miny];end % make sure miny is included as a point
   
   nrcols    = max(size(x));
   nrofrows  = max(size(y));

% create the dummy X, Y, Z and Ztemps grids

   X      = ones(nrofrows,1); X=X*x;      %X = roundoff(X, 6); - no longer needed if roundoff is already called above
   Y      = ones(1,nrcols);   Y=y'*Y;     %Y = roundoff(Y, 6); - no longer needed if roundoff is already called above 
   Z      = ones(size(X));    Z(:,:)=nan;
   Ztime  = Z;

% clear unused variables to save memory

   clear x y minx maxx miny maxy

% no one by one 

for i = 1:length(mapurls)

    % report on progress

    disp(' ')
    [pathstr, name, ext, versn] = fileparts(mapurls{i,1});
    disp(['Processing : ' name ext])
    
    % get data and plot

    [x, y, z, zt] = rws_getDataFromNetCDFGrid('ncfile', mapurls{i,1},...
                                           'starttime',OPT.starttime,...
                                        'searchwindow',OPT.searchwindow,...
                                             'polygon',OPT.polygon,...
                                              'stride',[1 1 1]);

% TO DO: do not read full array from netCDF but only data depending on thinning
% TO DO: use spatial mean, min, max in addition to nearest

    % convert vectors to grids

    x = repmat(x',size(z,1),1);
    y = repmat(y, 1, size(z,2));

    idsLargeGrid = ismember(X,x) & ismember(Y,y);
    idsSmallGrid = ismember(x,X) & ismember(y,Y);
    
    % clear unused variables to save memory

    clear x y
    
    % add values to Z matrix

    Z(idsLargeGrid) = z(idsSmallGrid);
    
    % add values to Ztemps matrix

    Ztime(idsLargeGrid) = zt(idsSmallGrid); 
    
    % clear unused variables to save memory

    clear z zt
    
end
