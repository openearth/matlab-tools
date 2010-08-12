function [d] = UCIT_getMetaData(type)
%UCIT_GETMETADATA   this routine gets meta data from the most convenient place
%
% This routine gets meta data from the most convenient place. The most
% convenient place is the userdata of the UCIT console. If no data is
% available there or if the available data does not match the puldown
% selection on the UCIT console a database query is performed. At the end
% of this query the data will be stored in the userdata of the UCIT console
% again.
%
%    d = UCIT_getMetaData(type)
%
% See also: ucit_netcdf

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%   Mark van Koningsveld
%   Ben de Sonneville
%
%       M.vankoningsveld@tudelft.nl
%       Ben.deSonneville@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$

if ~isnumeric(type)
    OPT      = type;
    datatype = OPT.datatype;
    type     = 2;
end

%% TRANSECT

if type == 1

    if ~(strcmp(UCIT_getInfoFromPopup('TransectsArea')    ,'Select area ...') && ...
         strcmp(UCIT_getInfoFromPopup('TransectsDatatype'),'Lidar Data US'  ))
        
    d = UCIT_getMetaData_transect;
    
    else
        d = [];
        errordlg('Select an area first')
    end
    
%% GRID
    
elseif type == 2
    
   d = UCIT_getMetaData_grid;

else
    d = [];
    errordlg('Select an area first')
end

if exist('OPT','var') 
    props = {'datatype','thinning','timewindow','inputyears','min_coverage','type'};
    for iprop = 1:length(props)
        try
            d.(props{iprop}) = OPT.(props{iprop});
        catch
            % Forget it.
        end
    end
end

