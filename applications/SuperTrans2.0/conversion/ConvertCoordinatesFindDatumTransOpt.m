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

%% find the transformation options
if OPT.CS1.geoRefSys.code == OPT.CS2.geoRefSys.code
    OPT.datum_trans = 'no datum transformation needed';
else
    [ OPT,ind,direction,ind_alt,dir_alt] = findTransOptions(OPT,STD,OPT.CS1.geoRefSys.code,OPT.CS2.geoRefSys.code,'datum_trans');
    if ~isempty(ind)
        % set parameters, name and code for datum transformation
        OPT.datum_trans.code          = STD.coordinate_operation.coord_op_code(ind);
        OPT.datum_trans.name          = STD.coordinate_operation.coord_op_name(ind);
        OPT.datum_trans.direction     = direction;
        if length(ind_alt)>1 % also include alternative tranformations
            OPT.datum_trans.alt_code      = STD.coordinate_operation.coord_op_code(ind_alt);
            OPT.datum_trans.alt_name      = STD.coordinate_operation.coord_op_name(ind_alt);
            OPT.datum_trans.alt_direction = dir_alt;
        end
        OPT.datum_trans.params        = ConvertCoordinatesFindDatumTransParams(STD.coordinate_operation.coord_op_code(ind),STD);
        OPT.datum_trans.method_code   = STD.coordinate_operation.coord_op_method_code(ind);
        OPT.datum_trans.method_name   = STD.coordinate_operation_method.coord_op_method_name{STD.coordinate_operation_method.coord_op_method_code == OPT.datum_trans.method_code};
        OPT.datum_trans.ellips1       = 'CS1';
        OPT.datum_trans.ellips2       = 'CS2';
    else
        % no direct transformation available, try via WGS 84
        OPT.datum_trans = 'no direct transformation available';
        % get ellips for WGS 84
         WGS84.datum.code = 6326;
         OPT.WGS84 = ConvertCoordinatesFindEllips(WGS84,STD);
         
        % geogcrs_code1 to WGS 84
        [ OPT,ind,direction,ind_alt,dir_alt] = findTransOptions(OPT,STD,OPT.CS1.geoRefSys.code,4326,'datum_trans_to_WGS84');
        if isempty(ind), error('no transformation available...'), end
        % get parameters, name and code for datum transformation TO wgs 84
        OPT.datum_trans_to_WGS84.code          = STD.coordinate_operation.coord_op_code(ind);
        OPT.datum_trans_to_WGS84.name          = STD.coordinate_operation.coord_op_name(ind);
        OPT.datum_trans_to_WGS84.direction     = direction;
        if length(ind_alt)>1 % also include alternative tranformations
            OPT.datum_trans_to_WGS84.alt_code      = STD.coordinate_operation.coord_op_code(ind_alt);
            OPT.datum_trans_to_WGS84.alt_name      = STD.coordinate_operation.coord_op_name(ind_alt);
            OPT.datum_trans_to_WGS84.alt_direction = dir_alt;
        end
        OPT.datum_trans_to_WGS84.params      = ConvertCoordinatesFindDatumTransParams(STD.coordinate_operation.coord_op_code(ind),STD);
        OPT.datum_trans_to_WGS84.method_code = STD.coordinate_operation.coord_op_method_code(ind);
        OPT.datum_trans_to_WGS84.method_name = STD.coordinate_operation_method.coord_op_method_name{STD.coordinate_operation_method.coord_op_method_code == OPT.datum_trans_to_WGS84.method_code};
        OPT.datum_trans_to_WGS84.ellips1     = 'CS1';
        OPT.datum_trans_to_WGS84.ellips2     = 'WGS84';

        % WGS 84 to geogcrs_code2
        [ OPT,ind,direction,ind_alt,dir_alt] = findTransOptions(OPT,STD,4326,OPT.CS2.geoRefSys.code,'datum_trans_from_WGS84');
        if isempty(ind), error('no transformation available...'), end
        % get parameters, name and code for datum transformation TO wgs 84
        OPT.datum_trans_from_WGS84.code          = STD.coordinate_operation.coord_op_code(ind);
        OPT.datum_trans_from_WGS84.name          = STD.coordinate_operation.coord_op_name(ind);
        OPT.datum_trans_from_WGS84.direction     = direction;
        if length(ind_alt)>1 % also include alternative tranformations
            OPT.datum_trans_from_WGS84.alt_code      = STD.coordinate_operation.coord_op_code(ind_alt);
            OPT.datum_trans_from_WGS84.alt_name      = STD.coordinate_operation.coord_op_name(ind_alt);
            OPT.datum_trans_from_WGS84.alt_direction = dir_alt;
        end
        OPT.datum_trans_from_WGS84.params      = ConvertCoordinatesFindDatumTransParams(STD.coordinate_operation.coord_op_code(ind),STD);
        OPT.datum_trans_from_WGS84.method_code = STD.coordinate_operation.coord_op_method_code(ind);
        OPT.datum_trans_from_WGS84.method_name = STD.coordinate_operation_method.coord_op_method_name{STD.coordinate_operation_method.coord_op_method_code == OPT.datum_trans_to_WGS84.method_code};
        OPT.datum_trans_from_WGS84.ellips1     = 'WGS84';
        OPT.datum_trans_from_WGS84.ellips2     = 'CS2';
    end
end

%% finally remove field OPT.datum_trans.code if it is empty
if isempty(OPT.datum_trans_to_WGS84.code)
    OPT = rmfield(OPT,'datum_trans_to_WGS84');
    OPT = rmfield(OPT,'WGS84');
    OPT = rmfield(OPT,'datum_trans_from_WGS84');  
end

end

function [ OPT,ind,direction,ind_alt,dir_alt] = findTransOptions(OPT,STD,geogcrs_code1,geogcrs_code2,datum_trans)
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

ind_alt = ind;
dir_alt = direction;
if ~isempty(OPT.(datum_trans).code)
    % user has defined input
    ii = find(STD.coordinate_operation.coord_op_code(ind_alt) == OPT.(datum_trans).code);
    if isempty(ii)
        error([sprintf(['user defined transformation code ''%d'' is not supported.\n'...
                       'choose from available options:\n'],OPT.(datum_trans).code),...
               sprintf('                     ''%d''\n',STD.coordinate_operation.coord_op_code(ind_alt))]);
    else
              ind = ind_alt(ii);
        direction = dir_alt{ii}; 
    end

% if no method has been defined by user, use the method found.
% If more options are found, use the method with the highest code 
% (it is assumed this value is the newest/best method)
else
    if length(ind_alt)>1
        [tmp,ii] = max(STD.coordinate_operation.coord_op_code(ind_alt));
        ind = ind_alt(ii);
        direction = dir_alt{ii};
    elseif length(ind_alt)==1
        ind = ind_alt;
        direction = direction{1};
    end
end
end