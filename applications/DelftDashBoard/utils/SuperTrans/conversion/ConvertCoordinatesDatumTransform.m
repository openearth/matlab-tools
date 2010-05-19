function [lat2,lon2] = ConvertCoordinatesDatumTransform(lat1,lon1,OPT,datum_trans)
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

% $Id: ConvertCoordinatesDatumTransform.m 2568 2009-11-12 14:27:10Z ormondt $
% $Date: 2009-11-12 15:27:10 +0100 (Thu, 12 Nov 2009) $
% $Author: ormondt $
% $Revision: 2568 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/mc_programs/DelftDashBoard/general/SuperTrans/conversion/ConvertCoordinatesDatumTransform.m $
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
            'Coordinate Frame rotation','Molodensky-Badekas 10-parameter transformation'}
        % convert geographic 2D coordinates to geographic 3D, by assuming
        % height is 0
        h    = zeros(size(lat1));
        
        % convert geographic 3D coordinates to geocentric coordinates
        a    = ell1.semi_major_axis;
        invf = ell1.inv_flattening;
        f    = 1/invf;
        e2   = 2*f-f^2;
        [x,y,z]=ell2xyz(lat1,lon1,h,a,e2);
        
        ii = strmatch('X-axis translation'            ,param.name); dx = inv*param.value(ii);
        ii = strmatch('Y-axis translation'            ,param.name); dy = inv*param.value(ii);
        ii = strmatch('Z-axis translation'            ,param.name); dz = inv*param.value(ii);
        switch method_name
            case 'Geocentric translations'
                [x,y,z]=Helmert3(x,y,z,dx,dy,dz);

            case {'Position Vector 7-param. transformation','Coordinate Frame rotation'}
                ii = strmatch('X-axis rotation'               ,param.name); rx = inv*param.value(ii)/1000000;
                ii = strmatch('Y-axis rotation'               ,param.name); ry = inv*param.value(ii)/1000000;
                ii = strmatch('Z-axis rotation'               ,param.name); rz = inv*param.value(ii)/1000000;
                ii = strmatch('Scale difference'              ,param.name); ds = inv*param.value(ii);
                if strcmp(method_name,'Coordinate Frame rotation')
                    rx=rx*-1;
                    ry=ry*-1;
                    rz=rz*-1;
                end
                [x,y,z]=Helmert7(x,y,z,dx,dy,dz,rx,ry,rz,ds);
            case {'Molodensky-Badekas 10-parameter transformation'} 
                ii = strmatch('X-axis rotation'               ,param.name); rx = inv*param.value(ii)/1000000;
                ii = strmatch('Y-axis rotation'               ,param.name); ry = inv*param.value(ii)/1000000;
                ii = strmatch('Z-axis rotation'               ,param.name); rz = inv*param.value(ii)/1000000;
                ii = strmatch('Scale difference'              ,param.name); ds = inv*param.value(ii);
                ii = strmatch('Ordinate 1 of evaluation point',param.name); xp =     param.value(ii);
                ii = strmatch('Ordinate 2 of evaluation point',param.name); yp =     param.value(ii);
                ii = strmatch('Ordinate 3 of evaluation point',param.name); zp =     param.value(ii);
                [x,y,z]=MolodenskyBadekas(x,y,z,dx,dy,dz,rx,ry,rz,xp,yp,zp,ds);
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



