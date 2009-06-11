function [x1,y1] = ConvertCoordinatesDatumTransform(x1,y1,datum_trans)

switch datum_trans.direction
    case 'normal',  inv =  1;
    case 'reverse', inv = -1;
end
param       = datum_trans.params;
method_name = datum_trans.method_name;

switch datum_trans.method_name
    case {'Geocentric translations','Position Vector 7-param',...
            'Coordinate Frame rotation','Molodensky-Badekas 10-parameter transformation'}
        % convert geographic 2D coordinates to geographic 3D, by assuming
        % height is 0
        h    = zeros(size(x1));
        
        % convert geographic 3D coordinates to geocentric coordinates
        a    = datum_trans.ellips1.semi_major_axis;
        invf = datum_trans.ellips1.inv_flattening;
        f    = 1/invf;
        e2   = 2*f-f^2;
        [x,y,z]=ell2xyz(y1,x1,h,a,e2);
        
        ii = strmatch('X-axis translation'            ,param.name); dx = inv*param.value(ii);
        ii = strmatch('Y-axis translation'            ,param.name); dy = inv*param.value(ii);
        ii = strmatch('Z-axis translation'            ,param.name); dz = inv*param.value(ii);
        switch method_name
            case 'Geocentric translations'
                [x,y,z]=Helmert3(x,y,z,dx,dy,dz);

            case {'Position Vector 7-param','Coordinate Frame rotation'}
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
        a     = datum_trans.ellips2.semi_major_axis;
        invf  = datum_trans.ellips2.inv_flattening;
        f     = 1/invf;
        e2    = 2*f-f^2;
        [y1,x1,h]=xyz2ell(x,y,z,a,e2);
    otherwise
        error(['Warning: Datum transformation method ''' method_name ''' not yet supported!']);
end



