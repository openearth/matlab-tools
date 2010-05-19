function CS = ConvertCoordinatesCheckInput(CS,STD)
%ConvertCoordinatesCheckInput .

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

% $Id: ConvertCoordinatesCheckInput.m 2568 2009-11-12 14:27:10Z ormondt $
% $Date: 2009-11-12 15:27:10 +0100 (Thu, 12 Nov 2009) $
% $Author: ormondt $
% $Revision: 2568 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/mc_programs/DelftDashBoard/general/SuperTrans/conversion/ConvertCoordinatesCheckInput.m $
% $Keywords: $

if ~isempty(CS.type)
    switch lower(CS.type)
        case {'geographic 2d','geo','geographic2d','latlon','lat lon','geographic'}
            CS.type = 'geographic 2D';
        case {'projected','xy','proj','cartesian','cart'}
            CS.type = 'projected';
        case {'engineering', 'geographic 3D', 'vertical', 'geocentric',  'compound'}
            error(['input ''CType = ' CS.type ''' is not (yet) supported']); 
        otherwise
            error(['coordinate type ''' CS.type ''' is not supported']);
    end
end

if ~isempty(CS.code)
    ind1              = find(STD.coordinate_reference_system.coord_ref_sys_code == CS.code);

    switch STD.coordinate_reference_system.coord_ref_sys_kind{ind1}

        case {'geographic 2D','projected'}
            % ok

        case {'compound'}
            CS.code = STD.coordinate_reference_system.cmpd_horizcrs_code(ind1); %#ok<FNDSB>
            disp(sprintf([...
                'coordinate system: ''%s'' is of type compound (3D coordinates system);\n'...
                'Only the 2D component is used in conversion;\n'...
                'conversion is performed for coordinate system %d'],...
                STD.coordinate_reference_system.coord_ref_sys_name{ind1},CS.code));
        otherwise
             error(['coordinate type '''...
                 STD.coordinate_reference_system.coord_ref_sys_kind{ind1}...
                 ''' is not supported']);
    end
end
    

