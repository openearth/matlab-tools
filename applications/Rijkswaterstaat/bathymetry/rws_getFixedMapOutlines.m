function OPeNDAPlinks = rws_getFixedMapOutlines(type,varargin)
%RWS_GETFIXEDMAPOUTLINES   Routine to retrieve information from OPeNDAP server
%
%   Syntax:
%   urls = opendap_getFixedMapOutlines(type)
%
%   Input:
%   	datatype = type indicator for fixed map dataset to use ('jarkus', 'vaklodingen')
%
%   Output:
%       urls     = function outputs the urls of all available fixed maps
%
%   Example:
%
% See also: rws_getDataInPolygon, rws_createFixedMapsOnAxes, 
%           rws_identifyWhichMapsAreInPolygon, rws_getDataFromNetCDFGrid

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

OPeNDAPlinks = [];

OPT.catalog  = [];
OPT.pattern  = '*.nc';
varargin{:}
OPT = setProperty(OPT,varargin{:})

if nargin == 0
    type = 'jarkus';
    warning('please specify datatype')
end

%% extract ncfile names from OPeNDAP info
if     strcmp(type,'vaklodingen')
    
    OPT.catalog = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml';

elseif strcmp(type,'jarkus')
    
    OPT.catalog = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/jarkus/grids/catalog.xml';

elseif strcmp(type,'multibeam_delfland')
    OPeNDAPlinks = findAllFiles( ...
        'pattern_excl', {[filesep,'.svn']}, ...                 
        'pattern_incl', OPT.pattern, ...                           
        'basepath'    , 'D:\checkouts\VO-rawdata\projects\154040_delflandse_kust\nc_files\multibeam\' ...	  
        );

elseif strcmp(type,'multibeam_delfland2')
    OPeNDAPlinks = findAllFiles( ...
        'pattern_excl', {[filesep,'.svn']}, ...            
        'pattern_incl', OPT.pattern, ...                        
        'basepath'    , 'D:\checkouts\VO-Delflandsekust\nc_files\multibeam\' ...	   
        );
end

if isempty(OPeNDAPlinks)
    if ~isempty(OPT.catalog)
    OPeNDAPlinks = getOpenDAPinfo('url', OPT.catalog);
    else
        error('catalog url and type is empty, please specify')
    end
end
