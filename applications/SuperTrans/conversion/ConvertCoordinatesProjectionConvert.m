function [y1,x1] = ConvertCoordinatesProjectionConvert(x1,y1,CS,proj_conv,direction,STD)
% CONVERTCOORDINATESPROJECTIONCONVERT 
%
% [y1,x1] = ...
% ConvertCoordinatesProjectionConvert(x1,y1,CS,proj_conv,direction,STD)
% 
% watch the order: lon-lat / x-y (NOT lat-lon !)

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
        ii = strmatch('Latitude of 2nd standard parallel'    ,param.name); lat2  = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);

        [x1,y1]= LambertConicConformal2SP(x1,y1,a,invf,lonf,fe,latf,fn,lat1,lat2,iopt);

    case 'Lambert Conic Conformal (2SP Belgium)'

        ii = strmatch('Longitude of false origin'            ,param.name); lonf  = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);
        ii = strmatch('Easting at false origin'              ,param.name); fe    = convertUnits(param.value(ii),param.UoM.name{ii},'metre',STD);
        ii = strmatch('Latitude of false origin'             ,param.name); latf  = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);
        ii = strmatch('Northing at false origin'             ,param.name); fn    = convertUnits(param.value(ii),param.UoM.name{ii},'metre',STD);
        ii = strmatch('Latitude of 1st standard parallel'    ,param.name); lat1  = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);
        ii = strmatch('Latitude of 2nd standard parallel'    ,param.name); lat2  = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);

        [x1,y1]= LambertConicConformal2SPBelgium(x1,y1,a,invf,lonf,fe,latf,fn,lat1,lat2,iopt);

    case 'Lambert Conic Conformal (1SP)'

        ii = strmatch('Latitude of natural origin'           ,param.name); lato  = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);
        ii = strmatch('Longitude of natural origin'          ,param.name); lono  = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);
        ii = strmatch('False easting'                        ,param.name); fe    = convertUnits(param.value(ii),param.UoM.name{ii},'metre',STD);
        ii = strmatch('False northing'                       ,param.name); fn    = convertUnits(param.value(ii),param.UoM.name{ii},'metre',STD);
        ii = strmatch('Scale factor at natural origin'       ,param.name); ko    = param.value(ii);

        [x1,y1]= LambertConicConformal1SP(x1,y1,a,invf,lato,lono,fe,fn,ko,iopt);
        
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

    case 'Oblique Mercator'

        ii = strmatch('Latitude of projection centre'        ,param.name); latc    = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);
        ii = strmatch('Longitude of projection centre'       ,param.name); lonc    = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);
        ii = strmatch('Azimuth of initial line'              ,param.name); alphac  = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);
        ii = strmatch('Angle from Rectified to Skew Grid'    ,param.name); gammac  = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);                                      
        ii = strmatch('Scale factor on initial line'         ,param.name); kc      = param.value(ii);      
        ii = strmatch('Easting at projection centre'         ,param.name); ec      = param.value(ii); 
        ii = strmatch('Northing at projection centre'        ,param.name); nc      = param.value(ii); 

        [x1,y1]= ObliqueMercator(x1,y1,a,invf,latc,lonc,alphac,gammac,kc,ec,nc,iopt);

    case 'Hotine Oblique Mercator'

        ii = strmatch('Latitude of projection centre'        ,param.name); latc    = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);
        ii = strmatch('Longitude of projection centre'       ,param.name); lonc    = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);
        ii = strmatch('Azimuth of initial line'              ,param.name); alphac  = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);
        ii = strmatch('Angle from Rectified to Skew Grid'    ,param.name); gammac  = convertUnits(param.value(ii),param.UoM.name{ii},'radian',STD);                                      
        ii = strmatch('Scale factor on initial line'         ,param.name); kc      = param.value(ii);      
        ii = strmatch('False easting'         ,param.name); fe      = param.value(ii); 
        ii = strmatch('False northing'        ,param.name); fn      = param.value(ii); 

        [x1,y1]= HotineObliqueMercator(x1,y1,a,invf,latc,lonc,alphac,gammac,kc,fe,fn,iopt);

    otherwise
        error(['tranformation method ' method.name ' not (yet) supported'])
end
end
