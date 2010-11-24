function UCIT_DC_takeAction(type)
%UCIT_DC_TAKEACTION   Routine performs selected action
%
% Routine performs selected action
%
% syntax:
%    UCIT_DC_takeAction(type)
% 
% input:
%    type =  1: transects, 2: grids, 3: lines, 4: points
%
% output:       
%    function has no output  
%
% see also UCIT_DC_getInfoFromPopup

% --------------------------------------------------------------------
% Copyright (C) 2004-2008 Delft University of Technology
% Version:  $Date$ (Version 1.0, January 2006)
%     M.van Koningsveld
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

% 1: transects, 2: grids, 3: lines
switch  type
    case 1
        objTag='TrActions';
    case 2
        objTag='GrActions';
    case 3
        objTag='LnActions';
    case 4
        objTag='PtActions';
end

[popupValue, info]=UCIT_getInfoFromPopup(objTag);

if info.value==1
    return
end

if strcmp(UCIT_getInfoFromPopup(objTag),'BuildDelft3dModel')
    eval([UCIT_getInfoFromPopup(objTag) '(' num2str(type) ');']);
else
    eval([UCIT_getInfoFromPopup(objTag) ';']);
end
