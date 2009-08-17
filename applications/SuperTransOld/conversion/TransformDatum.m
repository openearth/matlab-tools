function [lon2,lat2]=TransformDatum(lon1,lat1,ell1,ell2,trfcode,parameters,ireverse)
%TRANSFORMDATUM  transform datum
%
%[lon2,lat2]=TransformDatum(lon1,lat1,ell1,ell2,trfcode,parameters,ireverse)
%
%See also: 

lon2=lon1;
lat2=lat1;

switch trfcode,
    case {9603,9606,9607}
        a    =ell1.semi_major_axis;
        invf = ell1.inv_flattening;
        f    = 1/invf;
        e2   = 2*f-f^2;
        h    = zeros(size(lat1));
        [x,y,z]=ell2xyz(lat1,lon1,h,a,e2);
        switch trfcode,
            case 9603
                % 9603 Geocentric translations
                dx=ireverse*GetParameter(parameters,'X_axis_translation');
                dy=ireverse*GetParameter(parameters,'Y_axis_translation');
                dz=ireverse*GetParameter(parameters,'Z_axis_translation');
                [x,y,z]=Helmert3(x,y,z,dx,dy,dz);

            case {9606,9607}
                % 9606 Position Vector 7-param. transformation
                % 9607 Coordinate Frame rotation
                dx=ireverse*GetParameter(parameters,'X_axis_translation');
                dy=ireverse*GetParameter(parameters,'Y_axis_translation');
                dz=ireverse*GetParameter(parameters,'Z_axis_translation');
                rx=ireverse*GetParameter(parameters,'X_axis_rotation','rad');
                ry=ireverse*GetParameter(parameters,'Y_axis_rotation','rad');
                rz=ireverse*GetParameter(parameters,'Z_axis_rotation','rad');
                ds=ireverse*GetParameter(parameters,'Scale_difference');           
                if trfcode==9607
                    % 9607 Coordinate Frame rotation
                    rx=rx*-1;
                    ry=ry*-1;
                    rz=rz*-1;
                end
                [x,y,z]=Helmert7(x,y,z,dx,dy,dz,rx,ry,rz,ds);
        end
        a     = ell2.semi_major_axis;
        invf  = ell2.inv_flattening;
        f     = 1/invf;
        e2    = 2*f-f^2;
        [lat2,lon2,h]=xyz2ell(x,y,z,a,e2);
    otherwise
        disp('Warning: Datum transformation method not yet supported!');
end
clear lon1 lat1
