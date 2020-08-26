classdef ReferenceSystem < handle
    %Class to manage all the things about reference system
    %
    % @author ABR
    % @author SEO
    % @version 1.0, 04/14/04
    %
    properties
        Property1;
    end

    %Dependand properties
    properties (Dependent = true, SetAccess = private)

    end

    %Private properties
    properties(SetAccess = private)

    end

    %Default constructor
    methods
        function obj = Template(property1)
            if nargin > 0
                obj.Property1 = property1;
            end
        end
    end

    %Set methods
    methods
        function set.Property1(obj,property1)
            obj.Property1 = property1;
        end
    end

    %Get methods
    methods
        function property1 = get.Property1(obj)
            property1 = obj.Property1;
        end
    end

    %Public methods
    methods

    end

    %Private methods
    methods (Access = 'private')

    end

    %Stactic methods

    methods (Static)
        function dataset = convertReferenceSystem(dataFile, referenceSystemNew, zone)
            load(dataFile);
            %Convert coordinates
            switch dataset.coordinatesystem
                case 'WGS84-UTM31'
                    switch referenceSystemNew
                        case 'WGS84'
                        case 'ED50'
                            mCoord = ReferenceSystem.wgs84ToEd50([dataset.lat,dataset.long]);
                            dataset.lat = mCoord(:,1);
                            dataset.long = mCoord(:,2);
                    end;
                    mUTM = ReferenceSystem.geo2utm_wgs84([dataset.lat,dataset.long],zone);

                case 'ED50'
                    switch referenceSystemNew
                        case 'WGS84'
                            %TODO: NOT YET IMPLEMENTED
                            error('Not yet implemented');
                        case 'ED50'

                    end;
                    mUTM = ReferenceSystem.geo2utm_ed50([dataset.lat,dataset.long],zone);
            end;
            dataset.X = mUTM(:,1);
            dataset.Y = mUTM(:,2);

            save(dataFile, 'dataset')
        end;

        function mGeoED50 = wgs84ToEd50(geoEd50)
            %IMDC_Calc_GeoWGS842GeoED50
            %   mGeoED50 = IMDC_Calc_GeoWGS842GeoED50(geoEd50) transforms Geographical coordinates (N x 2 matrix Latitude Longitude in decimal degrees)
            %   in WGS84 ellipsoid to Geographical coordinates in ED50-International
            %   1924 Ellipsoid (Latitude Longitude). The used parameterset for this
            %   ellipsoid correspond to EUR-M (and not BEREF).
            %   geoEd50 and mGeoED50 are matrices with latitude values in the first 3
            %   columns (in degrees, minutes and seconds), longitude values in columns 4 to 6 (in degrees, minutes and second)
            %   and height in meters; the rest of the columns in geoEd50 are not processed and are passed to the output matrix.
            %   There is the possibility to have only 6 columns in geoEd50. In this
            %   case a zero height is assumed for all points in geoEd50.
            %   There is no option in this script to have more than 6 columns in
            %   geoEd50 and use zero height for all points (for these cases use: IMDC_Calc_GeoWGS842GeoED50_NoZ)
            %   Additional information about projections:
            %      http://www.ngi.be/NL/NL2-1-3.shtm
            %      K:\PROJECTS\11\11250 - WESP\10-Rap\NOTA\NOTA_11250_03165_TVD_WGS84_UTM.doc
            %   THIS TRANSFORMATION IS AN APPROXIMATION FOR COORDINATES IN BELGIUM!
            %   See also PCTrans software: http://www.hydro.nl/pgs/nl/pctrans_nl.htm
            %            K:\PROJECTS\11\11213 - Haventoegang Oostende\cd\omrekeningen

            if ~isnumeric(geoEd50)
                error('Input argument must be a matrix!')
            end
            if size(geoEd50,2)==6
                mGeoLat=geoEd50(:,1)+geoEd50(:,2)/60++geoEd50(:,3)/(60*60);
                mGeoLong=geoEd50(:,4)+geoEd50(:,5)/60++geoEd50(:,6)/(60*60);
                geoEd50=[mGeoLat,mGeoLong];
                clear mGeoLat mGeoLong
            end

            phi1 = geoEd50(:,1)*pi/180;
            lambda1 = geoEd50(:,2)*pi/180;
            if (size(geoEd50,2)>2)
                h1 = geoEd50(:,3);
            else
                h1 = zeros(size(geoEd50,1),1);
            end

            a1 = 6378137;
            f1 = 1.0/298.257223563;
            a2 = 6378388;
            f2 = 1.0/297.0;
            dx = 87;
            dy = 98;
            dz = 121;
            % The following parameters would be used if the parameterset for the
            % ellipsoid are for BEREF and not EUR-M)
            % I have noticed that using parameters for BEREF this function does not
            % give the same results produced by PCTrans software (close to those values
            % but up to 7 seconds difference) while using the values for EUR-M
            % parameterset gives exactly the same result from PCTrans
            % FTO 20.02.2006
            %dx = 131.404563;
            %dy = -52.795935;
            %dz = 130.23238;

            da = a2 - a1;
            df = f2 - f1;
            b = a1*(1. - f1);
            e2 = (a1*a1 - b*b)/(a1*a1);
            rm = a1*(1.0 - e2)./((1.0 - e2*sin(phi1).*sin(phi1)).^(3.0/2.0));
            rn = a1./(1.0 - e2*sin(phi1).*sin(phi1)).^0.5;
            dphi = -dx*sin(phi1).*cos(lambda1) - dy*sin(phi1).*sin(lambda1);
            dphi = dphi + dz*cos(phi1) + e2*da/a1*rn.*sin(phi1).*cos(phi1);
            dphi = dphi + df*(rm*a1/b + rn*b/a1).*sin(phi1).*cos(phi1);
            dphi = dphi./(rm + h1);
            dlambda =  -dx*sin(lambda1) + dy*cos(lambda1);
            dlambda = dlambda ./ ((rn + h1).*cos(phi1));
            dh = dx*cos(phi1).*cos(lambda1)+dy*cos(phi1).*sin(lambda1)+dz*sin(phi1);
            dh = dh - da*a1./rn + df*b/a1*rn.*sin(phi1).*sin(phi1);
            phi2 = phi1 + dphi;
            lambda2 = lambda1 + dlambda;
            h2 = h1 + dh;

            phi2Deg = phi2*180.0/pi;
            grdLat2 = floor(phi2Deg);
            minLat2 = floor((phi2Deg-grdLat2)*60);
            secLat2 = (phi2Deg-grdLat2-(minLat2/60))*60*60;

            lambda2Deg = lambda2*180.0/pi;
            grdLon2 = floor(lambda2Deg);
            minLon2 = floor((lambda2Deg-grdLon2)*60);
            secLon2 = (lambda2Deg-grdLon2-(minLon2/60))*60*60;

            nCols = size(geoEd50,2);

            if (nCols > 3)
                mGeoED50 = [phi2Deg lambda2Deg geoEd50(:,4:nCols)];
            elseif (nCols == 3)
                mGeoED50 = [phi2Deg lambda2Deg h2];
            else
                mGeoED50 = [phi2Deg lambda2Deg];
            end

            return;
        end;

        function mUTM = geo2utm_wgs84(mGeo,nZone)
            %IMDC_Calc_Geo2UTM_WGS84_everywhere
            %   mUTM = IMDC_Calc_Geo2UTM_WGS84_everywhere(mGeo,nZone) projects Geographical coordinates(Latitude Longitude in decimal degrees!) mGeo = a Nx2 matrix!
            %   to UTM projection system (in m). Geographical coordinates (and UTM result) are for
            %   WGS84 ellipsoid!!! (NOT ED50!!!!!).
            %   mUTM: matrix with easting and northing values
            %   mGeo is a matrix with latitude values in the first column (in decimal degrees; this can be negative) and longitude
            %   values in column 2 (in dec. degrees; this can be negative)); the rest of the columns are not processed and
            %   are passed to the output matrix mLambert which has X (in m) in the first column and Y (in m) in the second column.
            %   Additional information about projections:
            %      http://www.ngi.be/NL/NL2-1-3.shtm
            %      K:\PROJECTS\11\11250 - WESP\10-Rap\NOTA\NOTA_11250_03165_TVD_WGS84_UTM.doc
            %   THIS TRANSFORMATION IS AN APPROXIMATION FOR COORDINATES IN BELGIUM!
            %   See also PCTrans software: http://www.hydro.nl/pgs/nl/pctrans_nl.htm
            % A numeric value for the Zone should be added, so that this script can be used for most of the world, with the exception of SouthWest Norway and Svalbard, where the UTM zones are irregular, and which has not yer been implemented.
            % International Marine and Dredging Consultants (IMDC)
            % Antwerp, Belgium

            if ~isnumeric(mGeo)
                error('Input argument must be a matrix!')
            end

            fi = mGeo(:,1)*pi/180;
            lambda = mGeo(:,2)*pi/180;
            
            %ADDED FOR SOUTHERN HEMISPERE
            southern = fi<0;

            a_ell_p=6378137.0;
            f_ell_p=1.0/298.257223563;

            nMeridian =6.*(nZone -30)-3;
            lambda_0=nMeridian*(pi/180.0);

            k_0=0.9996;
            ff=f_ell_p;
            aa=a_ell_p;
            bb=aa*(1.0-ff);
            cc=aa*aa/bb;
            ea_2=(aa*aa-bb*bb)/(bb*bb);
            ea_4=ea_2*ea_2;
            ea_6=ea_4*ea_2;
            ea_8=ea_4*ea_4;
            A=cc*(1-(3.0*ea_2/4.0)+(45.0*ea_4/64.0)-(175.0*ea_6/256.0)+(11025.0*ea_8/16384.0));
            B=cc*(-(3.0*ea_2/8.0)+(15.0*ea_4/32.0)-(525.0*ea_6/1024.0)+(2205.0*ea_8/4096.0));
            C=cc*((15.0*ea_4/256.0)-(105.0*ea_6/1024.0)+(2205.0*ea_8/16384.0));
            D=cc*(-(35.0*ea_6/3072.0)+(315.0*ea_8/12288.0));

            eta_2=ea_2*cos(fi).*cos(fi);
            V=sqrt(1+eta_2);
            R=cc./V;
            G=A*fi+B*sin(2*fi)+C*sin(4*fi)+D*sin(6*fi);
            G_=R.*fi;
            dlambda=lambda-lambda_0;
            N_acc=k_0*R.*atan(tan(fi)./cos(dlambda));
            F=3.0*k_0*R.*eta_2.*cos(fi).*cos(fi).*cos(fi).*sin(fi)/8.0;
            N=N_acc+k_0*(G-G_)+F.*dlambda.*dlambda.*dlambda.*dlambda;
            E_acc=k_0*R.*log(tan(pi/4.0+0.5*asin(cos(fi).*sin(dlambda))));
            H=k_0*R.*eta_2.*cos(fi).*cos(fi).*cos(fi)/6.0;
            E=500000.0+E_acc+H.*dlambda.*dlambda.*dlambda;

            nCols = size(mGeo,2);

            if (nCols > 6)
                mUTM = [E N mGeo(:,7:nCols)];
            else
                mUTM = [E N];
            end
            
            %ADDED FOR SOUTHERN HEMISPERE
            mUTM(southern,2) = mUTM(southern,2) + 1e7;

            return;
        end;

        function mUTM = geo2utm_ed50(mGeo, nZone)
            %   mUTM = IMDC_Calc_Geo2UTM_ED50(mGeo,nZone) projects Geographical coordinates (Nx2 matrix Latitude Longitude, decimal degrees)
            %   to UTM projection system (in m). Geographical coordinates (and Lambert result) are for
            %   ED50-International 1924 ellipsoid!!! (NOT WGS84!!!!!).
            %   There is no problem of confusion here if the ED50 Ellipsoid is with
            %   parameter set EUR-M or BELREF because these are not relevant in the
            %   projection and in both case this script gives good results.
            %   mGeo is a matrix with latitude values in the first 3 columns (in degrees, minutes and seconds) and longitude
            %   values in columns 4 to 6 (in degrees, minutes and second); the rest of the columns are not processed and
            %   are passed to the output matrix mUTM which has X (in m) in the first column and Y (in m) in the second column.
            %   Additional information about projections:
            %      http://www.ngi.be/NL/NL2-1-3.shtm
            %      K:\PROJECTS\11\11250 - WESP\10-Rap\NOTA\NOTA_11250_03165_TVD_WGS84_UTM.doc
            %   THIS TRANSFORMATION IS AN APPROXIMATION FOR COORDINATES IN BELGIUM!
            %   See also PCTrans software: http://www.hydro.nl/pgs/nl/pctrans_nl.htm
            %
            % A numeric value for the Zone should be added, so that this script can be used for most of the world, with the exception of SouthWest Norway and Svalbard, where the UTM zones are irregular, and which has not yer been implemented.

            if ~isnumeric(mGeo)
                error('Input argument must be a matrix!')
            end

            fi = mGeo(:,1).*pi/180;
            lambda = mGeo(:,2).*pi/180;

            a_ell_p=6378388.0;
            f_ell_p=1.0/297.0;

            nMeridian =6.*(nZone -30)-3;
            lambda_0=nMeridian*(pi/180.0);

            k_0=0.9996;
            ff=f_ell_p;
            aa=a_ell_p;
            bb=aa*(1.0-ff);
            cc=aa*aa/bb;
            ea_2=(aa*aa-bb*bb)/(bb*bb);
            ea_4=ea_2*ea_2;
            ea_6=ea_4*ea_2;
            ea_8=ea_4*ea_4;
            A=cc*(1-(3.0*ea_2/4.0)+(45.0*ea_4/64.0)-(175.0*ea_6/256.0)+(11025.0*ea_8/16384.0));
            B=cc*(-(3.0*ea_2/8.0)+(15.0*ea_4/32.0)-(525.0*ea_6/1024.0)+(2205.0*ea_8/4096.0));
            C=cc*((15.0*ea_4/256.0)-(105.0*ea_6/1024.0)+(2205.0*ea_8/16384.0));
            D=cc*(-(35.0*ea_6/3072.0)+(315.0*ea_8/12288.0));

            eta_2=ea_2*cos(fi).*cos(fi);
            V=sqrt(1+eta_2);
            R=cc./V;
            G=A*fi+B*sin(2*fi)+C*sin(4*fi)+D*sin(6*fi);
            G_=R.*fi;
            dlambda=lambda-lambda_0;
            N_acc=k_0*R.*atan(tan(fi)./cos(dlambda));
            F=3.0*k_0*R.*eta_2.*cos(fi).*cos(fi).*cos(fi).*sin(fi)/8.0;
            N=N_acc+k_0*(G-G_)+F.*dlambda.*dlambda.*dlambda.*dlambda;
            E_acc=k_0*R.*log(tan(pi/4.0+0.5*asin(cos(fi).*sin(dlambda))));
            H=k_0*R.*eta_2.*cos(fi).*cos(fi).*cos(fi)/6.0;
            E=500000.0+E_acc+H.*dlambda.*dlambda.*dlambda;

            nCols = size(mGeo,2);

            if (nCols > 6)
                mUTM = [E N mGeo(:,7:nCols)];
            else
                mUTM = [E N];
            end

            return;
        end;

    end
end