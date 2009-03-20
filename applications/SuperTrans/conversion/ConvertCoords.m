function [x2,y2,err]=ConvertCoords(x1,y1,ell,trfcode,parameters,iopt)
%CONVERTCOORDS  convert coordinates
%
%[x2,y2,err]=ConvertCoords(x1,y1,ell,trfcode,parameters,iopt)
%
%See also:

% ft=0.3048;
  ft=1.0000;

a    = ell.semi_major_axis/ft;
invf = ell.inv_flattening;
err  = 0;

switch trfcode,
    case {9802} % Lambert Conic Conformal 2SP
        lonf   = GetParameter(parameters,'Longitude_of_false_origin','rad');
        fe     = GetParameter(parameters,'Easting_at_false_origin');
        latf   = GetParameter(parameters,'Latitude_of_false_origin','rad');
        fn     = GetParameter(parameters,'Northing_at_false_origin');
        lat1   = GetParameter(parameters,'Latitude_of_1st_standard_parallel','rad');
        lat2   = GetParameter(parameters,'Latitude_of_2nd_standard_parallel','rad');
        [x2,y2]= LambertConicConformal2SP(x1,y1,a,invf,lonf,fe,latf,fn,lat1,lat2,iopt);
    case {9803} % Lambert Conic Conformal 2SP (Belge)
        lonf   = GetParameter(parameters,'Longitude_of_false_origin','rad');
        fe     = GetParameter(parameters,'Easting_at_false_origin');
        latf   = GetParameter(parameters,'Latitude_of_false_origin','rad');
        fn     = GetParameter(parameters,'Northing_at_false_origin');
        lat1   = GetParameter(parameters,'Latitude_of_1st_standard_parallel','rad');
        lat2   = GetParameter(parameters,'Latitude_of_2nd_standard_parallel','rad');
        [x2,y2]= LambertConicConformal2SPBelgium(x1,y1,a,invf,lonf,fe,latf,fn,lat1,lat2,iopt);
    case {9807,9808} % Transverse Mercator        
        k0     = GetParameter(parameters,'Scale_factor_at_natural_origin');
        FE     = GetParameter(parameters,'False_easting');
        FN     = GetParameter(parameters,'False_northing');
        lat0   = GetParameter(parameters,'Latitude_of_natural_origin','rad');
        lon0   = GetParameter(parameters,'Longitude_of_natural_origin','rad');
        [x2,y2]= TransverseMercator(x1,y1,a,invf,k0,FE,FN,lat0,lon0,iopt);
    case 9809 % Oblique stereographic
        k0     = GetParameter(parameters,'Scale_factor_at_natural_origin');
        FE     = GetParameter(parameters,'False_easting');
        FN     = GetParameter(parameters,'False_northing');
        lat0   = GetParameter(parameters,'Latitude_of_natural_origin','rad');
        lon0   = GetParameter(parameters,'Longitude_of_natural_origin','rad');
        [x2,y2]= ObliqueStereographic(x1,y1,a,invf,k0,FE,FN,lat0,lon0,iopt);
    otherwise
        err=1;
end

clear x1 y1