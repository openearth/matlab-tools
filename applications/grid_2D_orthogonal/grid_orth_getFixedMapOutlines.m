function OPeNDAPlinks = grid_orth_getFixedMapOutlines(dataset)
%GRID_ORTH_GETFIXEDMAPOUTLINES   Routine retrieves fixed map information from OPeNDAP server or directory
%
%   Syntax:
%       OPeNDAPlinks = opendap_getFixedMapOutlines(dataset)
%
%   Input:
%   	dataset      = dataset indicator for fixed map dataset. Can either be an
%                      OpenDAP URl (should end on catalog.xml) or a directory (should
%                      contain one nc file or end on *.nc)
%
%   Output:
%       OPeNDAPlinks = function outputs the urls or directory listing of all available fixed maps
%
% See also: grid_orth_getDataInPolygon, grid_orth_createFixedMapsOnAxes, grid_orth_identifyWhichMapsAreInPolygon, getDataFromNetCDFGrid

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

if nargin == 0
    dataset = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml';
end

if strfind(dataset,'catalog.xml')
    OPeNDAPlinks = getOpenDAPinfo('url', dataset);
elseif strfind(dataset,'.nc')
    OPeNDAPlinks = findAllFiles( ...
        'pattern_excl', {[filesep,'.svn']}, ...
        'pattern_incl', '*.nc', ...
        'basepath', fileparts(dataset) ...
        );
else
    error('grid_orth:datasetError', ...
        'Indicated dataset cannot be found!')
end