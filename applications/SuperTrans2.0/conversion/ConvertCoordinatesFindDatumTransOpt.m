function [ OPT ] = ConvertCoordinatesFindDatumTransOpt(OPT,STD)
%CONVERTCOORDINATESFINDDATUMTRANSOPT .

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

if OPT.CS1.geoRefSys.code == OPT.CS2.geoRefSys.code
    OPT.datum_trans1 = 'no datum transformation needed';
else
    [ OPT,ind,direction ] = findTransOptions(OPT,STD,OPT.CS1.geoRefSys.code,OPT.CS2.geoRefSys.code);
    if isempty(ind)
        % no direct transformation available, try via WGS 84
        
        %get ellips for WGS 84
         WGS84.datum.code = 6326;
         WGS84 = ConvertCoordinatesFindEllips(WGS84,STD);
         
        % geogcrs_code1 to WGS 84
        [ OPT,ind,direction ] = findTransOptions(OPT,STD,OPT.CS1.geoRefSys.code,4326);
        if isempty(ind), error('no transformation available...'), end
        % get parameters, name and code for datum transformation TO wgs 84
        OPT.datum_trans1.direction   = direction;
        OPT.datum_trans1.params      = ConvertCoordinatesFindDatumTransParams(STD.coordinate_operation.coord_op_code(ind),STD);
        OPT.datum_trans1.method_code = STD.coordinate_operation.coord_op_method_code(ind);
        OPT.datum_trans1.method_name = STD.coordinate_operation_method.coord_op_method_name{STD.coordinate_operation_method.coord_op_method_code == OPT.datum_trans1.method_code};
        OPT.datum_trans1.ellips1     = OPT.CS1.ellips;
        OPT.datum_trans1.ellips2     = WGS84.ellips;

        % WGS 84 to geogcrs_code2
        [ OPT,ind,direction ] = findTransOptions(OPT,STD,4326,OPT.CS2.geoRefSys.code);
        if isempty(ind), error('no transformation available...'), end
        % get parameters, name and code for datum transformation
        OPT.datum_trans2.direction   = direction;
        OPT.datum_trans2.params      = ConvertCoordinatesFindDatumTransParams(STD.coordinate_operation.coord_op_code(ind),STD);
        OPT.datum_trans2.method_code = STD.coordinate_operation.coord_op_method_code(ind);
        OPT.datum_trans2.method_name = STD.coordinate_operation_method.coord_op_method_name{STD.coordinate_operation_method.coord_op_method_code == OPT.datum_trans2.method_code};
        OPT.datum_trans1.ellips1     = WGS84.ellips;
        OPT.datum_trans1.ellips2     = OPT.CS2.ellips;

    else
        % get parameters, name and code for datum transformation
        OPT.datum_trans1.direction   = direction;
        OPT.datum_trans1.params      = ConvertCoordinatesFindDatumTransParams(STD.coordinate_operation.coord_op_code(ind),STD);
        OPT.datum_trans1.method_code = STD.coordinate_operation.coord_op_method_code(ind);
        OPT.datum_trans1.method_name = STD.coordinate_operation_method.coord_op_method_name{STD.coordinate_operation_method.coord_op_method_code == OPT.datum_trans1.method_code};
        OPT.datum_trans1.ellips1     = OPT.CS1.ellips;
        OPT.datum_trans1.ellips2     = OPT.CS2.ellips;
    end
end
end

function [ OPT,ind,direction ] = findTransOptions(OPT,STD,geogcrs_code1,geogcrs_code2)
% find available transformation options
ind   = find(STD.coordinate_operation.source_crs_code == geogcrs_code1 &...
    STD.coordinate_operation.target_crs_code == geogcrs_code2);
direction(1:length(ind)) = {'normal'};

% also look for reverse operations
ind_r = find(STD.coordinate_operation.source_crs_code == geogcrs_code2 &...
    STD.coordinate_operation.target_crs_code == geogcrs_code1);

% check if found methods are reversible, only then add them to list 'ind'
% of possibilities.
reverse_method_codes = STD.coordinate_operation.coord_op_method_code(ind_r);
for ii = 1:length(reverse_method_codes)
    tmp = find(STD.coordinate_operation_method.coord_op_method_code == reverse_method_codes(ii));
    if strcmpi('TRUE',STD.coordinate_operation_method.reverse_op(ii))
        ind(end+1) = ind_r(ii);
        direction(end+1) = {'reverse'};
    end
end

% select method to use if more than one found. Use the method with the highest number,
% assuming this value is newest method
if length(ind)>1
    [tmp,ii] = max(STD.coordinate_operation.coord_op_code(ind));
    ind = ind(ii);
    direction = direction{ii};
elseif length(ind)==1
    direction = direction{1};
end
end