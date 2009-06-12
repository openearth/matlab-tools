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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
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
            error(['coordinate type ''' CS.type ''' is not known']);
    end
end
end
