function [y1,x1] = ConvertCoordinatesProjectionConvert(x1,y1,CS,proj_conv,direction,STD)
% CONVERTCOORDINATESPROJECTIONCONVERT 
% 
% watch the order of lat-lon / x-y!

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

switch direction
    case 'xy2geo', iopt = 0;
    case 'geo2xy', iopt = 1;
end
    
param  = proj_conv.param;
method = proj_conv.method;
ell    = CS.ellips;

a    = ell.semi_major_axis;
invf = ell.inv_flattening;

switch method.name
    case 'Lambert Conic Conformal (2SP)'

        ii = strmatch('Longitude of false origin'            ,param.name); lonf  = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);
        ii = strmatch('Easting at false origin'              ,param.name); fe    = convertUnits(param.value(ii),param.UoM.name{ii},'metre',STD);
        ii = strmatch('Latitude of false origin'             ,param.name); latf  = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);
        ii = strmatch('Northing at false origin'             ,param.name); fn    = convertUnits(param.value(ii),param.UoM.name{ii},'metre',STD);
        ii = strmatch('Latitude of 1st standard parallel'    ,param.name); lat1  = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);
        ii = strmatch('Latitude of 2st standard parallel'    ,param.name); lat2  = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);

        [x1,y1]= LambertConicConformal2SP(x1,y1,a,invf,lonf,fe,latf,fn,lat1,lat2,iopt);

    case 'Lambert Conic Conformal (2SP Belgium)'

        ii = strmatch('Longitude of false origin'            ,param.name); lonf  = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);
        ii = strmatch('Easting at false origin'              ,param.name); fe    = convertUnits(param.value(ii),param.UoM.name{ii},'metre',STD);
        ii = strmatch('Latitude of false origin'             ,param.name); latf  = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);
        ii = strmatch('Northing at false origin'             ,param.name); fn    = convertUnits(param.value(ii),param.UoM.name{ii},'metre',STD);
        ii = strmatch('Latitude of 1st standard parallel'    ,param.name); lat1  = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);
        ii = strmatch('Latitude of 2st standard parallel'    ,param.name); lat2  = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);


        [x1,y1]= LambertConicConformal2SPBelgium(x1,y1,a,invf,lonf,fe,latf,fn,lat1,lat2,iopt);
    case {'Transverse Mercator','Transverse Mercator (South Orientated)'}

        ii = strmatch('Scale factor at natural origin'       ,param.name); k0    = param.value(ii);
        ii = strmatch('False easting'                        ,param.name); FE    = convertUnits(param.value(ii),param.UoM.name{ii},'metre',STD);
        ii = strmatch('False northing'                       ,param.name); FN    = convertUnits(param.value(ii),param.UoM.name{ii},'metre',STD);
        ii = strmatch('Latitude of natural origin'           ,param.name); lat0  = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);
        ii = strmatch('Longitude of natural origin'          ,param.name); lon0  = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);

        [x1,y1]= TransverseMercator(x1,y1,a,invf,k0,FE,FN,lat0,lon0,iopt);
    case 'Oblique Stereographic'

        ii = strmatch('Scale factor at natural origin'       ,param.name); k0    = param.value(ii);
        ii = strmatch('False easting'                        ,param.name); FE    = convertUnits(param.value(ii),param.UoM.name{ii},'metre',STD);
        ii = strmatch('False northing'                       ,param.name); FN    = convertUnits(param.value(ii),param.UoM.name{ii},'metre',STD);
        ii = strmatch('Latitude of natural origin'           ,param.name); lat0  = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);                                          
        ii = strmatch('Longitude of natural origin'          ,param.name); lon0  = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);

        [x1,y1]= ObliqueStereographic(x1,y1,a,invf,k0,FE,FN,lat0,lon0,iopt);
    otherwise
        error(['tranformation method ' method.name ' not (yet) supported'])
end
end
