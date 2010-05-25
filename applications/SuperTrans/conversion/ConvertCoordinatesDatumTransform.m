function [lat2,lon2] = ConvertCoordinatesDatumTransform(lat1,lon1,OPT,datum_trans,STD)
%CONVERTCOORDINATESDATUMTRANSFORM .

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

switch OPT.(datum_trans).direction
    case 'normal',  inv =  1;
    case 'reverse', inv = -1;
end
param       = OPT.(datum_trans).params;
method_name = OPT.(datum_trans).method_name;
ell1        = OPT.(OPT.(datum_trans).ellips1).ellips;
ell2        = OPT.(OPT.(datum_trans).ellips2).ellips;

switch method_name
    case {'Geocentric translations','Position Vector 7-param. transformation',...
            'Coordinate Frame rotation','Coordinate Frame Rotation (geog2D domain)',...
            'Molodensky-Badekas 10-parameter transformation'}
        % convert geographic 2D coordinates to geographic 3D, by assuming
        % height is 0
        h    = zeros(size(lat1));
        
        % convert geographic 3D coordinates to geocentric coordinates
        a    = ell1.semi_major_axis;
        invf = ell1.inv_flattening;
        f    = 1/invf;
        e2   = 2*f-f^2;
        [x,y,z]=ell2xyz(lat1,lon1,h,a,e2);

        switch method_name

            case 'Geocentric translations'

                dx = inv*getParamValue(param,'X-axis translation','metre',STD);
                dy = inv*getParamValue(param,'Y-axis translation','metre',STD);
                dz = inv*getParamValue(param,'Z-axis translation','metre',STD);
                [x,y,z]=Helmert3(x,y,z,dx,dy,dz);

            case {'Position Vector 7-param. transformation','Coordinate Frame rotation','Coordinate Frame Rotation (geog2D domain)'}

                dx = inv*getParamValue(param,'X-axis translation','metre',STD);
                dy = inv*getParamValue(param,'Y-axis translation','metre',STD);
                dz = inv*getParamValue(param,'Z-axis translation','metre',STD);
                rx = inv*getParamValue(param,'X-axis rotation','radian',STD);
                ry = inv*getParamValue(param,'Y-axis rotation','radian',STD);
                rz = inv*getParamValue(param,'Z-axis rotation','radian',STD);
                ds = inv*getParamValue(param,'Scale difference','',STD);
                if any(strcmp(method_name,{'Coordinate Frame rotation','Coordinate Frame Rotation (geog2D domain)'}))
                    rx=rx*-1;
                    ry=ry*-1;
                    rz=rz*-1;
                end
                [x,y,z]=Helmert7(x,y,z,dx,dy,dz,rx,ry,rz,ds);

            case {'Molodensky-Badekas 10-parameter transformation'} 

                dx = inv*getParamValue(param,'X-axis translation','metre',STD);
                dy = inv*getParamValue(param,'Y-axis translation','metre',STD);
                dz = inv*getParamValue(param,'Z-axis translation','metre',STD);
                rx = inv*getParamValue(param,'X-axis rotation','radian',STD);
                ry = inv*getParamValue(param,'Y-axis rotation','radian',STD);
                rz = inv*getParamValue(param,'Z-axis rotation','radian',STD);
                ds = inv*getParamValue(param,'Scale difference','',STD);
                xp = inv*getParamValue(param,'Ordinate 1 of evaluation point','',STD);
                yp = inv*getParamValue(param,'Ordinate 2 of evaluation point','',STD);
                zp = inv*getParamValue(param,'Ordinate 3 of evaluation point','',STD);
                [x,y,z]=MolodenskyBadekas(x,y,z,dx,dy,dz,rx,ry,rz,xp,yp,zp,ds);

            case 'NADCON'
%                [x,y,z]=NADCON(x,y,z);
        
        end

        % convert geocentric coordinates to geographic 3D coordinates 
        a     = ell2.semi_major_axis;
        invf  = ell2.inv_flattening;
        f     = 1/invf;
        e2    = 2*f-f^2;
        [lat2,lon2,h]=xyz2ell(x,y,z,a,e2);
        % and just forget about h...
    otherwise
        error(['Warning: Datum transformation method ''' method_name ''' not yet supported!']);
end

%% 
function val = getParamValue(param,name,unit,STD)

ii = strmatch(name,param.name);
if ~isempty(unit)
    val  = convertUnits(param.value(ii),param.UoM.sourceN{ii},unit,STD);
else
    val = param.value(ii);
end


